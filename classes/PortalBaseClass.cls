/** It is a portal base class, get current user infor
*
*   Author : 2CloudNine Ying Liu
**/
public virtual class PortalBaseClass {

	private Id uId = UserInfo.getUserId();
	protected User currentUser;
	
	public PortalBaseClass(){
		//change to portal user once link to portal 
		currentUser = [Select FirstName, LastName, ContactId, Contact.FirstName, Contact.LastName from User where id =: uId limit 1];
		
		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=IE8');
		
	}
	
}