global with sharing class scrud{
    private class sexception extends exception {}

    global static void screate(sobject o){
        screate(new list<sobject>{o});
    }

    global static void screate(list<sobject> os){
        if (os == null || os.size() == 0){
            return;
        }
        
        // Get Describe Result of the SObject
        Schema.SObjectType targetType = os[0].getSObjectType();
        if (targetType == null) {
            sexception e = new sexception();
            e.setMessage('Object not found.');
            throw e;
        }

        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        
        // !! Attention to Governor Limit: Up to 100 call
        // Get map of all fileds exist in the SObject
        map<string, schema.sObjectField> m = sobjResult.fields.getMap();
        
        // Initiate set to manage fields to create
        set<schema.describeFieldResult> descFields_to_create = new set<schema.describeFieldResult>();
        
        // Loop all fields exist in the object
        for (String key : m.keySet()) {
            schema.describeFieldResult descField = m.get(key).getDescribe();
            
            // Loop every records to create and collect the fields to create
            for (sobject o : os){
                try {
                    if (o.get(descField.getName()) != null){
                        descFields_to_create.add(descField);
                        break;
                    } 
                } catch (SObjectException e){
                    // The object does not contain this field so go to scan next field.
                    continue;
                }
            }
        }
            
        // Check FLS on each field to create
        for (schema.Describefieldresult descField : descFields_to_create){
            if (!descField.isCreateable()){
                sexception e = new sexception();
                e.setMessage('Field: ' + descField.getName() + ' is not createable.');
                throw e;
            }
        }
        
        insert os;
    }
    
    global static sobject sread(string objName, id rid){
        return sread(objName, rid, null);
    }
    
    global static sobject sread(string objName, id rid, list<string> flds){
        string field_to_read = '';
        
        Schema.SObjectType targetType = schema.getGlobalDescribe().get(objName);
        if (targetType == null) {
            sexception e = new sexception();
            e.setMessage('Object not found.');
            throw e;
        }
        
        if (flds == null){
            // retrieve all fields
            Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
            
            // !! Attention to Governor Limit: Up to 100 call
            map<string, schema.sObjectField> m = sobjResult.fields.getMap();
            
            for (String key : m.keySet()) {
                if (!m.get(key).getDescribe().isAccessible()){
                    continue;
                }
                schema.describeFieldResult descField = m.get(key).getDescribe();
                field_to_read += descField.getName() + ',';
            }
        } else {
            // retrieve specified fields
            // !! Attention to Governor Limit: Up to 100 call
            map<string, schema.sObjectField> m = targetType.getDescribe().fields.getMap();
            
            for (string f : flds){
                if (!m.get(f).getDescribe().isAccessible()){
                    continue;
                }
                field_to_read += f + ',';
            }
        }
        if (field_to_read == ''){
            sexception e = new sexception();
            e.setMessage('No field can be retrieved.');
            throw e;
        }
        field_to_read = field_to_read.removeEnd(',');
        
        string soql = 'select ' + field_to_read + ' from ' + objName + ' where id = :rid';
        list<sObject> records;
        try {
            records = Database.query(soql);
        } catch (QueryException e){
            system.debug('Error ocurred on executing SOQL: ' + soql);
            throw e;
        }

        if (records.size() == 0){
            return null;
        }
        return records[0];
    }
    
    global static void supdate(sobject o){
        supdate(new list<sobject>{o}, false);
    }
    
    global static void supdate(list<sobject> os){
        supdate(os, false);
    }
    
    global static void supdate(sobject o, boolean strict){
        supdate(new list<sobject>{o}, strict);
    }
    
    global static void supdate(list<sobject> os, boolean strict){
        if (os == null || os.size() == 0){
            return;
        }
        
        Schema.SObjectType targetType = os[0].getSObjectType();
        if (targetType == null) {
            sexception e = new sexception();
            e.setMessage('Object not found.');
            throw e;
        }
        
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        
        // !! Attention to Governor Limit: Up to 100 call
        map<string, schema.sObjectField> m = sobjResult.fields.getMap();
        
        // Loop all fields exist in the object
        list<sobject> os4u = new list<sobject>();
        for (sobject o : os){
            sobject o4u = targetType.newSObject(o.id);
            boolean update_required = false;
            
            // Add field if it is updateable.
            for (String key : m.keySet()) {
                schema.describeFieldResult descField = m.get(key).getDescribe();
                try {
                    if (o.get(descField.getName()) != null){
                        system.debug('Object contains ' + descField.getname());
                        if (strict == true && !descField.isUpdateable()){
                            sexception e = new sexception();
                            e.setMessage('Field: ' + descField.getName() + ' is not updateable.');
                            throw e;
                        }
                        if (descField.isUpdateable()){
                            o4u.put(descField.getName(), o.get(descField.getName()));
                            update_required = true;
                        }
                    }
                } catch (SObjectException e){
                    // The object does not contain this field so go to scan next field.
                    continue;
                }
            }
            
            // Add record to update list if there is at least 1 field to udpate.
            if (update_required){
                os4u.add(o4u);
            }
        }

        update os4u;
    }
    
    global static void supsert(sobject o){
        supsert(o, false);
    }
    
    global static void supsert(sobject o, boolean strict){
        Schema.SObjectType targetType = o.getSObjectType();
        sobject o4u = targetType.newSObject(o.id);
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        
        // !! Attention to Governor Limit: Up to 100 call
        map<string, schema.sObjectField> m = sobjResult.fields.getMap();
        
        for (String key : m.keySet()) {
            schema.describeFieldResult descField = m.get(key).getDescribe();
            
            try {
                if (o.get(descField.getName()) != null){
                    if (strict == true && (!descField.isCreateable() || !descField.isUpdateable())){
                        sexception e = new sexception();
                        e.setMessage('Field: ' + descField.getName() + ' is not upsertable.');
                        throw e;
                    }
                    if (descField.isCreateable() && descField.isUpdateable()){
                        // Add field to o4u
                        o4u.put(descField.getName(), o.get(descField.getName()));
                    }
                }
            } catch (SObjectException e){
                // The object does not contain this field so go to scan next field.
                continue;
            }
            
        }
        upsert o4u;
    }
    
    global static void sdelete(sobject o){
        sdelete(new list<sObject>{o});
    }
    
    global static void sdelete(list<sobject> os){
        if (os == null || os.size() == 0){
            return;
        }

        if (!os[0].getSObjectType().getDescribe().isDeletable()){
            sexception e = new sexception();
            e.setMessage('Object: ' + os[0].getSObjectType().getDescribe().getName() + ' is not deletable.');
            throw e;
        }
        delete os;
    }
    
    global static list<sObject> slist(string objName){
        string field_to_read = '';
        
        Schema.SObjectType targetType = schema.getGlobalDescribe().get(objName);
        if (targetType == null) {
            sexception e = new sexception();
            e.setMessage('Object not found.');
            throw e;
        }
        
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        
        // !! Attention to Governor Limit: Up to 100 call
        map<string, schema.sObjectField> m = sobjResult.fields.getMap();
        
        for (String key : m.keySet()) {     
            if (!m.get(key).getDescribe().isAccessible()){
                continue;
            }
            schema.describeFieldResult descField = m.get(key).getDescribe();
            field_to_read += descField.getName() + ',';
        }
        
        if (field_to_read == ''){
            sexception e = new sexception();
            e.setMessage('No field can be retrieved.');
            throw e;
        }
        field_to_read = field_to_read.removeEnd(',');
        
        string soql = 'select ' + field_to_read + ' from ' + objName + ' order by CreatedDate desc';
        list<sObject> records;
        try {
            records = Database.query(soql);
        } catch (QueryException e){
            system.debug('Error ocurred on executing SOQL: ' + soql);
            throw e;
        }

        if (records.size() == 0){
            return null;
        }
        return records;
    }

    global static void requireAccessible(string objName){
        requireAccessible(objName, getFields(objName));
    }

    global static void requireAccessible(string objName, list<string> flds){
        Schema.SObjectType targetType = schema.getGlobalDescribe().get(objName);
        if (targetType == null) {
            sexception e = new sexception();
            e.setMessage('Object: ' + objName + ' not found.');
            throw e;
        }
        
        // !! Attention to Governor Limit: Up to 100 call
        map<string, schema.sObjectField> m = targetType.getDescribe().fields.getMap();
        
        for (string f : flds){
            if (m.get(f) == null){
                sexception e = new sexception();
                e.setMessage('Field: ' + f + ' not found.');
                throw e;
            }
            if (!m.get(f).getDescribe().isAccessible()){
                sexception e = new sexception();
                e.setMessage('Field: ' + f + ' is not accessible.');
                throw e;
            }
        }
    }
    
    global static boolean isAccessible(string objName){
        return isAccessible(objName, getFields(objName));
    }
    
    global static boolean isAccessible(string objName, list<string> flds){
        Schema.SObjectType targetType = schema.getGlobalDescribe().get(objName);
        if (targetType == null) {
            sexception e = new sexception();
            e.setMessage('Object not found.');
            throw e;
        }
        
        // !! Attention to Governor Limit: Up to 100 call
        map<string, schema.sObjectField> m = targetType.getDescribe().fields.getMap();
        
        for (string f : flds){
            if (m.get(f) == null){
                sexception e = new sexception();
                e.setMessage('Field: ' + f + ' not found.');
                throw e;
            }
            if (!m.get(f).getDescribe().isAccessible()){
                return false;
            }
        }
        
        return true;
    }
    
    global static list<string> getFields(string objName){
        list<string> flds = new list<string>();
        
        Schema.SObjectType targetType = schema.getGlobalDescribe().get(objName);
        if (targetType == null) {
            sexception e = new sexception();
            e.setMessage('Object not found.');
            throw e;
        }
        
        // !! Attention to Governor Limit: Up to 100 call
        map<string, schema.sObjectField> m = targetType.getDescribe().fields.getMap();
        flds = new list<string>(m.keySet());
        
        return flds;
    }

    private static list<string> getOperationalFields(string operation, string objName, boolean allFields){
        list<string> flds = new list<string>();
        
        Schema.SObjectType targetType = schema.getGlobalDescribe().get(objName);
        if (targetType == null) {
            sexception e = new sexception();
            e.setMessage('Object not found.');
            throw e;
        }
        
        // !! Attention to Governor Limit: Up to 100 call
        map<string, schema.sObjectField> m = targetType.getDescribe().fields.getMap();
        for (String key : m.keySet()) {
            boolean need_to_add = false;

            if (allFields){
                need_to_add = true;
            } else if (key.contains('__c') || key == 'Id' || key == 'Name'){
                need_to_add = true;
            }

            if (need_to_add){
                schema.describeFieldResult descField = m.get(key).getDescribe();
                if (operation == 'create'){
                    if (descField.isCreateable()){
                        flds.add(descField.getName());
                    }
                } else if (operation == 'read'){
                    if (descField.isAccessible()){
                        flds.add(descField.getName());
                    }
                } else if (operation == 'update'){
                    if (descField.isUpdateable()){
                        flds.add(descField.getName());
                    }
                } else if (operation == 'upsert'){
                    if (descField.isCreateable() && descField.isUpdateable()){
                        flds.add(descField.getName());
                    }
                } else {
                    sexception e = new sexception();
                    e.setMessage('Unsupported operation.');
                    throw e;
                }
            } 
        }
        
        if (flds.size() == 0){
            return null;
        }
        
        return flds;
    }

    global static list<string> getCreateableFields(string objName){
        return getOperationalFields('create', objName, false);
    }

    global static string getCreateableFieldsInCSV(string objName){
        list<string> flds = getOperationalFields('create', objName, false);
        string fldsInCSV = '';
        for (string fld : flds){
            fldsInCSV += fld + ',';
        }
        fldsInCSV = fldsInCSV.removeEnd(',');
        return fldsInCSV;
    }

    global static list<string> getAccessibleFields(string objName){
        return getOperationalFields('read', objName, false);
    }
    
    global static list<string> getAccessibleFields(string objName, boolean allFields){
        return getOperationalFields('read', objName, allFields);
    }

    global static string getAccessibleFieldsInCSV(string objName){
        return getAccessibleFieldsInCSV(objName, false);
    }

    global static string getAccessibleFieldsInCSV(string objName, boolean allFields){
        list<string> flds = getOperationalFields('read', objName, allFields);
        string fldsInCSV = '';
        for (string fld : flds){
            fldsInCSV += fld + ',';
        }
        fldsInCSV = fldsInCSV.removeEnd(',');
        return fldsInCSV;
    }

    global static list<string> getUpdateableFields(string objName){
        return getOperationalFields('update', objName, false);
    }

    global static string getUpdateableFieldsInCSV(string objName){
        list<string> flds = getOperationalFields('update', objName, false);
        string fldsInCSV = '';
        for (string fld : flds){
            fldsInCSV += fld + ',';
        }
        fldsInCSV = fldsInCSV.removeEnd(',');
        return fldsInCSV;
    }

    global static list<string> getUpsertableFields(string objName){
        return getOperationalFields('upsert', objName, false);
    }

    global static string getUpsertableFieldsInCSV(string objName){
        list<string> flds = getOperationalFields('upsert', objName, false);
        string fldsInCSV = '';
        for (string fld : flds){
            fldsInCSV += fld + ',';
        }
        fldsInCSV = fldsInCSV.removeEnd(',');
        return fldsInCSV;
    }
}