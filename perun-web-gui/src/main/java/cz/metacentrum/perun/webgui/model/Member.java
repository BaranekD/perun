package cz.metacentrum.perun.webgui.model;

import com.google.gwt.core.client.JavaScriptObject;

/**
 * Overlay type for Member object from Perun
 *
 * @author Vaclav Mach <374430@mail.muni.cz>
 * @author Pavel Zlamal <256627@mail.muni.cz>
 */
public class Member extends JavaScriptObject {

	protected Member() { }

	// JSNI methods to get Member data

	public final native int getId() /*-{
		return this.id;
	}-*/;

	public final native int getVoId() /*-{
		return this.voId;
	}-*/;

	public final native int getUserId() /*-{
		return this.userId;
	}-*/;

	public final native int getSourceGroupId() /*-{
		if (!this.sourceGroupId) {
			return 0;
		}
		return this.sourceGroupId;
	}-*/;

	/**
	 * Get membership type (context associated on member's retrieval)
	 *
	 * @return membership type (DIRECT, INDIRECT, NOT_DEFINED, ....)
	 */
	public final native String getMembershipType() /*-{
		if (!this.membershipType) {
			return "NOT_DETERMINED";
		} else {
			return this.membershipType;
		}
	}-*/;

	/**
	 * Returns Perun specific type of object
	 *
	 * @return type of object
	 */
	public final native String getObjectType() /*-{
		if (!this.beanName) {
			return "JavaScriptObject"
		}
		return this.beanName;
	}-*/;

	/**
	 * Sets Perun specific type of object
	 *
	 * @param type type of object
	 */
	public final native void setObjectType(String type) /*-{
		this.beanName = type;
	}-*/;

	/**
	 * Returns the status of this item in Perun system as String
	 * VALID, INVALID, SUSPENDED, EXPIRED, DISABLED
	 *
	 * @return string which defines item status
	 */
	public final native String getStatus() /*-{
		return this.status;
	}-*/;

	/**
	 * Compares to another object
	 * @param o Object to compare
	 * @return true, if they are the same
	 */
	public final boolean equals(Member o)
	{
		return o.getId() == this.getId();
	}

}
