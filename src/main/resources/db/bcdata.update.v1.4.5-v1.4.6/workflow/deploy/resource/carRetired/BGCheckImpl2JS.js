bc.namespace("bswf.carRetired");
bswf.carRetired.BGCheckImplForm = {
	init : function(option,readonly){
		var $form = $(this);
	},
	/** 表单验证方法 */
	validateForm: function(){
		if(!bc.validator.validate(this))
			return false;
		return true;
	}
};