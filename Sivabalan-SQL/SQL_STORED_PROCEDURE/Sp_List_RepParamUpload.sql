CREATE Procedure Sp_List_RepParamUpload(@Paramid int)
As
	Select ParameterId,Parameter_Type,
	"Parameter Name"=Parameter_name,
	"Parameter Value"=Replace(Parameter_Value,N'$',N'')
	From ReportParameters_Upload
	Where ParameterID=@Paramid


