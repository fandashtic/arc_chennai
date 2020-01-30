Create procedure [dbo].[Sp_Acc_Update_Setup]  	
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
      @ORGANISATIONTYPE INT,      
      @NUMBEROFPARTNERS INT,      
          @DRAWINGACCOUNTFLAG INT = NULL,      
      @AUTHORISATIONCAPITAL DECIMAL(18,6) = NULL,      
      @REGISTRATIONDATE DATETIME = NULL,      
      @BUSINESSCOMDATE DATETIME = NULL,      
      @TINNUMBER nVarchar(20) = N'',      
      @SALESPORTAL nVarchar(100) = N'',      
      @LOCALIZEDNAME nVarchar(255) = N'',      
      @InstallationType Int =0,      
      @CompanyId_FXS nVarchar(2000) = N'',
	  @WDCode as nVarchar(10) = N'',
	  @WDDestnCode as nVarchar(10) = N'',
	  @BStateID Int = 0,
	  @SStateID Int = 0,
	  @BusinessNatureID Int = 0,
	  @GSTIN nVarChar(15) = N'',
	  @CIN nVarChar(21) = N''
	  )
	        
AS      
If @ORGANISATIONTYPE <=2      
Begin      
 Update [Setup]       
 SET BillingAddress=@BillingAddress,      
     ShippingAddress=@ShippingAddress,      
     Telephone=@Telephone,      
     FiscalYear=@FISCALYEAR,      
     VoucherStart=@VoucherStart,      
     STRegn = @STREGN,      
     STLabel = @STLABEL,      
     CTRegn = @CTREGN,      
     CTLabel = @CTLABEL,       
     DL20 = @DL20,      
     DL21 = @DL21,      
     OrganisationType=@ORGANISATIONTYPE,      
     NumberofPartners=@NUMBEROFPARTNERS,      
     DrawingAccountFlag=@DRAWINGACCOUNTFLAG,       
     TIN_Number = @TINNUMBER,       
     SalesPortalIP = @SALESPORTAL,       
  LocalizedName = @LOCALIZEDNAME,      
  InstallationType = @InstallationType,      
  CugForumCode = @CompanyId_FXS ,
   WDCode = @WDCode,
   WDDestCode  = @WDDestnCode,
   BillingStateID  = @BStateID,
   ShippingStateID = @SStateID,
   BusinessNatureID = @BusinessNatureID,
   GSTIN = @GSTIN  ,
   CIN = @CIN  
    
where RegisteredOwner=@CompanyID      
End      
Else If @ORGANISATIONTYPE = 3      
Begin      
 Update [Setup]       
 SET BillingAddress=@BillingAddress,      
     ShippingAddress=@ShippingAddress,      
     Telephone=@Telephone,      
     FiscalYear=@FISCALYEAR,      
     VoucherStart=@VoucherStart,      
     STRegn = @STREGN,      
     STLabel = @STLABEL,      
     CTRegn = @CTREGN,      
     CTLabel = @CTLABEL,       
     DL20 = @DL20,      
     DL21 = @DL21,      
     OrganisationType=@ORGANISATIONTYPE,      
     AuthorisationCapital=@AUTHORISATIONCAPITAL,      
     RegistrationDate=@REGISTRATIONDATE,      
     TIN_Number = @TINNUMBER,      
     SalesPortalIP = @SALESPORTAL,       
   LocalizedName = @LOCALIZEDNAME,       
  InstallationType = @InstallationType,      
  CugForumCode = @CompanyId_FXS,
   WDCode = @WDCode,
   WDDestCode  = @WDDestnCode,
   BillingStateID  = @BStateID,
   ShippingStateID = @SStateID,
   BusinessNatureID = @BusinessNatureID,
   GSTIN = @GSTIN,
   CIN = @CIN     
	
 where RegisteredOwner=@CompanyID      
End      
Else If @ORGANISATIONTYPE = 4      
Begin      
 Update [Setup]       
 SET BillingAddress=@BillingAddress,      
     ShippingAddress=@ShippingAddress,      
     Telephone=@Telephone,      
     FiscalYear=@FISCALYEAR,      
     VoucherStart=@VoucherStart,      
     STRegn = @STREGN,      
     STLabel = @STLABEL,      
     CTRegn = @CTREGN,      
     CTLabel = @CTLABEL,       
     DL20 = @DL20,      
     DL21 = @DL21,      
     OrganisationType=@ORGANISATIONTYPE,      
     AuthorisationCapital=@AUTHORISATIONCAPITAL,      
     RegistrationDate=@REGISTRATIONDATE,      
     BusinessCommencementDate=@BUSINESSCOMDATE,      
     TIN_Number = @TINNUMBER,      
     SalesPortalIP = @SALESPORTAL,       
  LocalizedName = @LOCALIZEDNAME,      
  InstallationType = @InstallationType,      
  CugForumCode = @CompanyId_FXS,
   WDCode = @WDCode,
   WDDestCode  = @WDDestnCode,
   BillingStateID  = @BStateID,
   ShippingStateID = @SStateID,
   BusinessNatureID = @BusinessNatureID,
   GSTIN = @GSTIN ,
   CIN = @CIN    
	
 where RegisteredOwner=@CompanyID      
End      
