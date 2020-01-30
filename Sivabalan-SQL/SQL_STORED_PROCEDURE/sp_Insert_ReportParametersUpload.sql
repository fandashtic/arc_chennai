Create Procedure sp_Insert_ReportParametersUpload ( @ParameterID Int,
						    @ParameterName nvarchar(255),
						    @ParameterValue nvarchar(255),
						    @ParameterType Int)
As
Insert Into ReportParameters_Upload (ParameterID, Parameter_Name, Parameter_Value,
Parameter_Type) Values (@ParameterID, @ParameterName, @ParameterValue, @ParameterType)
