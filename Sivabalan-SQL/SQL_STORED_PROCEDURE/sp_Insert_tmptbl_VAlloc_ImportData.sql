CREATE PROCEDURE sp_Insert_tmptbl_VAlloc_ImportData
(
@CustID nVarChar(50),
@CustName nVarChar(255),
@GSTFullDocID nVarChar(255),
@DocNo nVarChar(255),
@InvDate nVarChar(10),
@InvVal Decimal(18,6),
@Salesman nVarChar(255),
@Beat nVarChar(255),
@Zone nVarChar(255),
@Van nVarChar(50),
@VADate nVarChar(10),
@SeqNo Int,
@ShipmentNo Int
)
AS  
Begin
	Set DateFormat DMY
		
	INSERT INTO #tmpImportData
	(CustID,CustName,GSTFullDocID,DocNo,InvDate,InvVal,Salesman,Beat,Zone,Van,VADate,SeqNo,ShipmentNo)
	Values
	(@CustID,@CustName,@GSTFullDocID,@DocNo,@InvDate,@InvVal,@SalesMan,@Beat,@Zone,@Van,@VADate,@SeqNo,@ShipmentNo)	
	
End
