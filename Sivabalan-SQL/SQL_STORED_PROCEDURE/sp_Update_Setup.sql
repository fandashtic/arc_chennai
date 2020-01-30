
CREATE procedure [sp_Update_Setup]
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
		  @DL21 nvarchar(50))

AS Update [Setup] 
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
    DL21 = @DL21 where RegisteredOwner=@CompanyID



