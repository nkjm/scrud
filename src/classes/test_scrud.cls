@isTest
public with sharing class test_scrud {
	private static testmethod void test_screate(){
		account a1 = new account(name = 'khdijfbeirfn');
		scrud.screate(a1);
		system.assertNotEquals(null, a1.id);
	}

	private static testmethod void test_sread(){
		account a1 = new account(name = 'khdijfbeirfn');
		scrud.screate(a1);
		account a2 = (account)scrud.sread('Account',a1.id);
		system.assertEquals(a1.name, a2.name);
	}

	private static testmethod void test_supdate(){
		account a1 = new account(name = 'khdijfbeirfn');
		scrud.screate(a1);
		a1.name = 'ueroioegldkfj';
		scrud.supdate(a1);
		account a2 = (account)scrud.sread('Account',a1.id);
		system.assertEquals('ueroioegldkfj', a2.name);
	}

	private static testmethod void test_supsert(){
		account a1 = new account(name = 'khdijfbeirfn');
		scrud.screate(a1);
		a1.name = 'ueroioegldkfj';
		scrud.supsert(a1);
		account a2 = (account)scrud.sread('Account',a1.id);
		system.assertEquals('ueroioegldkfj', a2.name);
	}

	private static testmethod void test_sdelete(){
		account a1 = new account(name = 'khdijfbeirfn');
		scrud.screate(a1);
		scrud.sdelete(a1);
		system.assertEquals(0, [select id from account where name = 'khdijfbeirfn'].size());
	}

	private static testmethod void test_squery(){
		account a1 = new account(name = 'khdijfbeirfn');
		scrud.screate(a1);
		list<sobject> sos = scrud.squery('select id, name from account where name = \'khdijfbeirfn\'');
		boolean account_found = false;
		for (sobject so : sos){
			account a = (account)so;
			if (a.name == 'khdijfbeirfn'){
				account_found = true;
			}
		}
		system.assertEquals(true, account_found);
	}

	private static testmethod void test_slist(){
		account a1 = new account(name = 'khdijfbeirfn');
		scrud.screate(a1);
		list<sobject> sos = scrud.slist('account');
		boolean account_found = false;
		for (sobject so : sos){
			account a = (account)so;
			if (a.name == 'khdijfbeirfn'){
				account_found = true;
			}
		}
		system.assertEquals(true, account_found);
	}

	private static testmethod void test_requireAccessible(){
		scrud.requireAccessible('account');
		system.assertEquals(1,1);
	}

	private static testmethod void test_isAccessible(){
		system.assertEquals(true, scrud.isAccessible('account'));
	}

	private static testmethod void test_getCreateableFields(){
		list<string> fs = scrud.getCreateableFields('account');
		boolean phone_found = false;
		boolean CustomerPriority_found = false;
		for (string f : fs){
			if (f.toLowerCase() == 'phone'){
				phone_found = true;
			}
			if (f.toLowerCase() == 'CustomerPriority__c'){
				CustomerPriority_found = true;
			}
		}
		system.assertEquals(false, phone_found);
		system.assertEquals(true, CustomerPriority_found);
	}

	private static testmethod void test_getCreateableFieldsInCSV(){
		string field_csv = scrud.getCreateableFieldsInCSV('account');
		list<string> fs = field_csv.split(',', 0);
		boolean phone_found = false;
		boolean CustomerPriority_found = false;
		for (string f : fs){
			if (f.toLowerCase() == 'phone'){
				phone_found = true;
			}
			if (f.toLowerCase() == 'CustomerPriority__c'){
				CustomerPriority_found = true;
			}
		}
		system.assertEquals(false, phone_found);
		system.assertEquals(true, CustomerPriority_found);
	}

	private static testmethod void test_getAccessbileFields(){
		list<string> fs = scrud.getAccessibleFields('account');
		boolean phone_found = false;
		boolean CustomerPriority_found = false;
		for (string f : fs){
			if (f.toLowerCase() == 'phone'){
				phone_found = true;
			}
			if (f.toLowerCase() == 'CustomerPriority__c'){
				CustomerPriority_found = true;
			}
		}
		system.assertEquals(false, phone_found);
		system.assertEquals(true, CustomerPriority_found);

		fs = scrud.getAccessibleFields('account', true);
		phone_found = false;
		CustomerPriority_found = false;
		for (string f : fs){
			if (f.toLowerCase() == 'phone'){
				phone_found = true;
			}
			if (f.toLowerCase() == 'CustomerPriority__c'){
				CustomerPriority_found = true;
			}
		}
		system.assertEquals(true, phone_found);
		system.assertEquals(true, CustomerPriority_found);
	}

	private static testmethod void test_getAccessbileFieldsInCSV(){
		string field_csv = scrud.getAccessibleFieldsInCSV('account');
		list<string> fs = field_csv.split(',', 0);
		boolean phone_found = false;
		boolean CustomerPriority_found = false;
		for (string f : fs){
			if (f.toLowerCase() == 'phone'){
				phone_found = true;
			}
			if (f.toLowerCase() == 'CustomerPriority__c'){
				CustomerPriority_found = true;
			}
		}
		system.assertEquals(false, phone_found);
		system.assertEquals(true, CustomerPriority_found);

		field_csv = scrud.getAccessibleFieldsInCSV('account', true);
		fs = field_csv.split(',', 0);
		phone_found = false;
		CustomerPriority_found = false;
		for (string f : fs){
			if (f.toLowerCase() == 'phone'){
				phone_found = true;
			}
			if (f.toLowerCase() == 'CustomerPriority__c'){
				CustomerPriority_found = true;
			}
		}
		system.assertEquals(true, phone_found);
		system.assertEquals(true, CustomerPriority_found);
	}

	private static testmethod void test_getUpdateableFields(){
		list<string> fs = scrud.getUpdateableFields('account');
		boolean phone_found = false;
		boolean CustomerPriority_found = false;
		for (string f : fs){
			if (f.toLowerCase() == 'phone'){
				phone_found = true;
			}
			if (f.toLowerCase() == 'CustomerPriority__c'){
				CustomerPriority_found = true;
			}
		}
		system.assertEquals(false, phone_found);
		system.assertEquals(true, CustomerPriority_found);
	}

	private static testmethod void test_getUpdateableFieldsInCSV(){
		string field_csv = scrud.getUpdateableFieldsInCSV('account');
		list<string> fs = field_csv.split(',', 0);
		boolean phone_found = false;
		boolean CustomerPriority_found = false;
		for (string f : fs){
			if (f.toLowerCase() == 'phone'){
				phone_found = true;
			}
			if (f.toLowerCase() == 'CustomerPriority__c'){
				CustomerPriority_found = true;
			}
		}
		system.assertEquals(false, phone_found);
		system.assertEquals(true, CustomerPriority_found);
	}

	private static testmethod void test_getUpsertableFields(){
		list<string> fs = scrud.getUpsertableFields('account');
		boolean phone_found = false;
		boolean CustomerPriority_found = false;
		for (string f : fs){
			if (f.toLowerCase() == 'phone'){
				phone_found = true;
			}
			if (f.toLowerCase() == 'CustomerPriority__c'){
				CustomerPriority_found = true;
			}
		}
		system.assertEquals(false, phone_found);
		system.assertEquals(true, CustomerPriority_found);
	}

	private static testmethod void test_getUpsertableFieldsInCSV(){
		string field_csv = scrud.getUpsertableFieldsInCSV('account');
		list<string> fs = field_csv.split(',', 0);
		boolean phone_found = false;
		boolean CustomerPriority_found = false;
		for (string f : fs){
			if (f.toLowerCase() == 'phone'){
				phone_found = true;
			}
			if (f.toLowerCase() == 'CustomerPriority__c'){
				CustomerPriority_found = true;
			}
		}
		system.assertEquals(false, phone_found);
		system.assertEquals(true, CustomerPriority_found);
	}

}