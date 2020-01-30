
CREATE Procedure sp_insert_Setup
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
AS INSERT INTO [Setup]
               (RegisteredOwner,
                OrganisationTitle,
                BillingAddress,
                ShippingAddress,
                Telephone,
                FiscalYear,
                VoucherStart,
		STRegn,
		STLabel,
		CTRegn,
		CTLabel,
		DL20,
		DL21)
Values
               (@COMPANYID,
                @CompanyNAME,
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
		@DL21)      



