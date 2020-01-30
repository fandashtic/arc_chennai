
CREATE PROCEDURE sp_get_DocFooter_UOM  
 @DocType nvarchar(10),  
 @DocID nvarchar(15)  
 AS  
BEGIN  
	IF @DocType ='PO'  
	BEGIN  
		SELECT * FROM [PODetail] WHERE PONumber = @DocID  
	END  
	else IF @DocType ='SRE'  
	BEGIN  
		SELECT * FROM [stock_request_Detail] WHERE Stock_Req_Number = @DocID  
	END  
	ELSE IF @DocType ='SO'  
	BEGIN  
		SELECT * FROM SODetail WHERE SONumber = @DocID  
	END  
	ELSE IF @DocType = 'INVOICE'  
	BEGIN  
		SELECT Product_Code,InvoiceID, Batch_Number,Serial,max(UOM) uom,max(UOMPrice)UOMPrice,max(SalePrice) SalePrice ,max(SaleID) SaleID,
			max(MRP) MRP, max(Batch_Code) Batch_Code, sum(Quantity) Quantity, max(TaxCode) as taxcode, max(DiscountPercentage) as DiscountPercentage, sum(DiscountValue) DiscountValue, 
			sum(Amount) amount, max(PurchasePrice) PurchasePrice, sum(STPayable) STPayable, max(PTR) PTR, max(PTS) PTS,max(TAXID) as TaxId, sum(CSTPAYABLE) CSTPAYABLE,max(TAXCODE2) as taxcode2,max(TAXSUFFERED)TAXSUFFERED ,max(TAXSUFFERED2)TAXSUFFERED2, 
			max(REASONID)REASONID,max(COMBOID)COMBOID,sum(SCHEMEDISCAMOUNT)SCHEMEDISCAMOUNT,sum(SPLCATDISCAMOUNT)SPLCATDISCAMOUNT,max(ExciseID)ExciseID,max(salesstaffid) salesstaffid,
			max(SCHEMEID)SCHEMEID, max(sPLCATSCHEMEID) sPLCATSCHEMEID,max(SCHEMEDISCPERCENT) SCHEMEDISCPERCENT,max(SPLCATDISCPERCENT) SPLCATDISCPERCENT,max(TaxSuffApplicableOn) TaxSuffApplicableOn, max(TaxSuffPartOff) TaxSuffPartOff,
			max(VAT) VAT,max(CollectTaxSuffered) CollectTaxSuffered,sum(TAXAMOUNT) TAXAMOUNT, sum(TAXSUFFAMOUNT) TAXSUFFAMOUNT,sum(STCREDIT) STCREDIT,max(TaxApplicableOn) TaxApplicableOn,max(TaxPartOff) TaxPartOff,
			sum(UOMQty) UOMQty,max(flagWord) flagWord, max(freeSerial) freeSerial, max(SPLCATSerial) SPLCATSerial, max(SpecialCategoryScheme) SpecialCategoryScheme,
			max(SalePriceBeforeExciseAmount) SalePriceBeforeExciseAmount,sum(ExciseDuty) ExciseDuty
		FROM INVOICEDetail    
		WHERE InvoiceID = @DocID    
		GROUP BY Product_Code, InvoiceID, Serial, Batch_Number
	END  
END  
	


