Create Procedure mERP_spr_RecdDocStatus_Det_ITC    
(    
 @scrcode nvarchar(500),    
 @FromDate Datetime,    
 @ToDate Datetime)    
As
Declare @WDCode NVarchar(255)  
Declare @WDDest NVarchar(255)  
Declare @CompaniesToUploadCode NVarchar(255)  
    
Begin     

	Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload    
	Select Top 1 @WDCode = RegisteredOwner From Setup      
	    
	If @CompaniesToUploadCode='ITC001'    
		Set @WDDest= @WDCode    
	Else    
	Begin    
		Set @WDDest= @WDCode    
		Set @WDCode= @CompaniesToUploadCode    
	End    

	declare @NewScrCode nvarchar(500)    
	set @NewScrCode =''    
	    
	If @scrcode='Channel'    
		set @NewScrCode='CHL001'    
	else If @scrcode='CategoryGroupDefinition'    
		set @NewScrCode='CGD001'    
	else If @scrcode='CategoryHandlerConfig'    
		set @NewScrCode='CHC001'    
	else If @scrcode='Add New Category'    
		set @NewScrCode='CTG01'     
	else If @scrcode='Modify Category'    
		set @NewScrCode='CTG02'     
	else If @scrcode='Import Category Add'    
		set @NewScrCode='CTG03'     
	else If @scrcode='Import Category Modify'    
		set @NewScrCode='CTG04'     
	else If @scrcode='Add New Item'    
		set @NewScrCode='ITM01'     
	else If @scrcode='Add Item Variant'    
		set @NewScrCode='ITM02'    
	else If @scrcode='Modify Item'    
		set @NewScrCode='ITM03'    
	else If @scrcode='Import Item Add'    
		set @NewScrCode='ITM04'    
	else If @scrcode='Import Item Modify'    
		set @NewScrCode='ITM05'    
	else If @scrcode='Add New Customer'    
		set @NewScrCode= 'CST01'    
	else If @scrcode='Modify Customer'    
		set @NewScrCode='CST02'    
	else If @scrcode='Import Customer Add'    
		set @NewScrCode='CST03'     
	else If @scrcode='Import Customer Modify'    
		set @NewScrCode='CST04'    
	else If @scrcode='Import Customer TMD Add'    
		set @NewScrCode='CST05'    
	else If @scrcode='Import Customer TMD Modify'     
		set @NewScrCode='CST06'    
	ELSE     
		set @NewScrCode=@scrcode    
	    
	select  @WDCode,@WDCode as 'WD Code', @WDDest as 'WD Dest Code',@FromDate as 'From Date',@ToDate as 'To Date',Transactiontype,errMessage as 'Error Message',keyvalue as 'Key value',cast(Processdate as nvarchar) as 'Process Date' from tbl_mERP_RecdErrMessages where processdate Between @FromDate And @ToDate    
	and transactiontype=@NewScrCode    
	ORDER BY PROCESSDATE ASC    
End 
