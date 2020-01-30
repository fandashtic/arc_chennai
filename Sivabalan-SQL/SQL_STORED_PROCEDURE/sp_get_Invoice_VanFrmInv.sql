CREATE procedure [dbo].[sp_get_Invoice_VanFrmInv](         
@FromDate	DATETIME,        
@ToDate		DATETIME,        
@FLAG		Int = 256,
@BeatID		Int = 0,
@FromSNO	Decimal (18,6)  = 0,
@ToSNO		Decimal (18,6)  = 0,		 	
@BeatParam 	NVarchar(4000) = N''
)         
AS  
SET NOCOUNT ON
Create Table #TblBeat (BeatID Int)      

If @BeatId=0
	if @BeatParam <> N''	
		INSERT INTO #TblBeat SELECT * FROM sp_SplitIn2Rows(@BeatParam,',')
	Else
	Begin
		insert into #tblbeat select beatid from beat
		insert into #tblbeat values(0)
	End
Else
	INSERT INTO #TblBeat Values (@BeatID)

/* Sequence Number fields are not present in the application */
IF (@FromSNO =0 And @ToSNO =0) 
BEGIN 
	SELECT 
		InvoiceAbstract.CustomerID AS "CustomerID", 
		Company_Name, 
		InvoiceID, 
		InvoiceDate,         
		NetValue, 
		InvoiceType, 
		DocumentID, 
		ISNULL(Status, 0), 
		ISNULL(VanNumber,N''), 
		ISNULL((SELECT 
				Sum(Isnull(InvDet.Quantity,0) * Isnull(ConversionFactor,0))
			FROM 
				InvoiceDetail InvDet, Items   
			WHERE 
					InvDet.InvoiceID = InvoiceAbstract.InvoiceID 
				AND  	InvDet.Product_Code = Items.Product_Code),0) "Weight",
		Beat.Description as "Beat",Customer.SequenceNo     
	FROM 
		InvoiceAbstract, Customer,Beat        
	WHERE 
			(InvoiceType = 1 OR InvoiceType = 3)           
		AND 	InvoiceAbstract.BeatID*=Beat.BeatID
		AND 	InvoiceAbstract.BeatID IN (Select BeatID From #TblBeat)
		AND 	InvoiceAbstract.CustomerID = Customer.CustomerID         
		AND 	InvoiceDate between @FromDate and @ToDate     
		AND 	(ISNULL(Status,0) & 128) = 0   
	--AND (ISNULL(Status,0) & @FLAG)= 256    
	ORDER BY 
		(Case Isnull(VanNumber, N'')       
			When N'' Then 0      
			Else 1      
		End),  InvoiceID Asc       
END 
/* Sequence Numbers are given */
ELSE
BEGIN
	SELECT 
		InvoiceAbstract.CustomerID AS "CustomerID", 
		Company_Name, 
		InvoiceID, 
		InvoiceDate,         
		NetValue, 
		InvoiceType, 
		DocumentID, 
		ISNULL(Status, 0), 
		ISNULL(VanNumber,N''), 
		ISNULL((SELECT 
				Sum(Isnull(InvDet.Quantity,0) * Isnull(ConversionFactor,0))
			FROM 
				InvoiceDetail InvDet, Items   
			WHERE 
					InvDet.InvoiceID = InvoiceAbstract.InvoiceID 
				AND  	InvDet.Product_Code = Items.Product_Code),0) "Weight",
		Beat.Description as "Beat",Customer.SequenceNo     
	FROM 
		InvoiceAbstract, Customer,Beat        
	WHERE 
			(InvoiceType = 1 OR InvoiceType = 3)           
		AND 	InvoiceAbstract.BeatID *= Beat.BeatID
		AND 	InvoiceAbstract.BeatID In (Select BeatID From #TblBeat)
		AND	Customer.SequenceNo between @FromSNO and @ToSNO
		AND 	InvoiceAbstract.CustomerID = Customer.CustomerID         
		AND 	InvoiceDate between @FromDate and @ToDate     
		AND 	(ISNULL(Status,0) & 128) = 0   
	--AND (ISNULL(Status,0) & @FLAG)= 256    
	ORDER BY       
		Customer.SequenceNo,InvoiceDate    

END
Drop Table #TblBeat
SET NOCOUNT OFF
