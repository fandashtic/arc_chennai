Create PROCEDURE sp_acc_Save_Setup  
                 (@COMPANYID NVARCHAR (50),      
                  @COMPANYNAME NVARCHAR (255),         
                  @BILLINGADDRESS NVARCHAR (255),      
                  @SHIPPINGADDRESS NVARCHAR (255),      
                  @TELEPHONE NVARCHAR (50),      
                  @FISCALYEAR INT,      
                  @VOUCHERSTART INT,      
      			@STREGN nvarchar(50),      
      @STLABEL nvarchar(50),      
      @CTREGN nvarchar(50),      
      @CTLABEL nvarchar(50),      
      @DL20 nvarchar(50),      
      @DL21 nvarchar(50),      
      @ORGANISATIONTYPE INT = NULL,      
      @NUMBEROFPARTNERS INT = NULL,      
      @DRAWINGACCOUNTFLAG INT = NULL,      
      @AUTHORISATIONCAPITAL DECIMAL(18,6) = NULL,      
      @REGISTRATIONDATE DATETIME = NULL,      
      @BUSINESSCOMDATE DATETIME = NULL,      
      @TINNUMBER nvarchar(20) = N'',      
      @SALESPORTAL nvarchar(100) = N'',      
      @LOCALIZEDNAME nVarchar(255) = N'',      
      @InstallationType Int =0,      
      @CompanyId_FXS nVarchar(2000) = N'',
	  @WDCode as nVarchar(10) = N'',
	  @WDDestnCode as nVarchar(10) = N'',
	  @CompanyToUpload as nVarchar(50) = N'',
	  @BStateID Int = 0,
	  @SStateID Int = 0,
	  @BusinessNatureID Int = 0,
	  @GSTIN nVarChar(15) = N'',
	  @CIN nVarChar(21) = N''
	  )
AS      


IF EXISTS (SELECT TOP 1 RegisteredOwner FROM Setup WHERE RegisteredOwner = @CompanyID)      
BEGIN      
 EXEC sp_acc_update_setup @COMPANYID,      
                  @COMPANYNAME,         
                  @BILLINGADDRESS,      
                  @SHIPPINGADDRESS,      
                  @TELEPHONE,      
                  @FISCALYEAR,      
                  @VOUCHERSTART,      
      @STREGN,      
      @STLABEL,      
      @CTREGN,      
      @CTLABEL,      
      @DL20,      
      @DL21,      
      @ORGANISATIONTYPE,      
      @NUMBEROFPARTNERS,      
      @DRAWINGACCOUNTFLAG,      
      @AUTHORISATIONCAPITAL,      
      @REGISTRATIONDATE,      
      @BUSINESSCOMDATE,      
       @TINNUMBER,      
      @SALESPORTAL,      
      @LOCALIZEDNAME,      
      @InstallationType,      
      @CompanyId_FXS ,
	  @WDCode	     ,
	  @WDDestnCode	,
	  @BStateID ,
	  @SStateID ,
	  @BusinessNatureID ,
	  @GSTIN,
	  @CIN
      
END      
ELSE      
BEGIN      
 EXEC sp_acc_insert_Setup @COMPANYID,      
                  @COMPANYNAME,         
                  @BILLINGADDRESS,      
                  @SHIPPINGADDRESS,      
                  @TELEPHONE,      
                  @FISCALYEAR,      
                  @VOUCHERSTART,      
      @STREGN,      
      @STLABEL,      
      @CTREGN,      
      @CTLABEL,      
      @DL20,      
      @DL21,      
      @ORGANISATIONTYPE,      
      @NUMBEROFPARTNERS,      
      @DRAWINGACCOUNTFLAG,      
      @AUTHORISATIONCAPITAL,      
      @REGISTRATIONDATE,      
      @BUSINESSCOMDATE,      
      @TINNUMBER,      
      @SALESPORTAL,      
      @LOCALIZEDNAME,      
      @InstallationType,      
      @CompanyId_FXS ,
	  @WDCode,     
      @WDDestnCode,
      @BStateID ,
	  @SStateID ,
	  @BusinessNatureID ,
	  @GSTIN,
	  @CIN

END      
IF @CompanyToUpload <> N''
Begin
	if Not Exists(Select * From Companies_To_Upload)
		Insert Into Companies_To_Upload(ID,ForumCode) Values (1,@CompanyToUpload)
	else
		Update Companies_To_Upload Set ForumCode  = @CompanyToUpload Where ID = 1
End

