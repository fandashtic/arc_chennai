CREATE Procedure sp_acc_rpt_TBDrilldowncount (@fromdate datetime,@todate datetime ,@parentid  integer,  @TBType nvarchar(50) = null,@docref integer,@doctype integer,@mode integer,@Info nvarchar(4000) = Null,@State Int=0,@Hide0BalAC Int =0)
as
DECLARE @LEAFACCOUNT integer            
DECLARE @ACCOUNTGROUP integer           
DECLARE @NEXTLEVEL integer              
DECLARE @NONEXTLEVEL integer            


IF @TBType = 2    
Begin    
	SET @LEAFACCOUNT =5    
End    
Else    
Begin    
	SET @LEAFACCOUNT =2              
End    
SET @ACCOUNTGROUP =3              
SET @NEXTLEVEL =0              
SET @NONEXTLEVEL =1              

IF @mode = @ACCOUNTGROUP               
BEGIN              
    create Table #ACCOUNTGROUP
	(GroupName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),
	TBType Int,GroupID integer,fromdate datetime ,todate datetime,
	DocRef integer, DocType integer,ColorInfo1 Int,ColorInfo2 Int)

	Insert into #ACCOUNTGROUP
	Exec sp_acc_rpt_trialbalancegroupwise @fromdate ,@todate ,@parentid  ,@TBType ,@docref ,@doctype ,@mode ,@Info ,@State ,@Hide0BalAC
	Select count(*) from #ACCOUNTGROUP
	Drop table #ACCOUNTGROUP
end
ELSE IF @mode=@LEAFACCOUNT               
BEGIN              
	Create table #LEAFACCOUNT
	(TransactionDate datetime, OriginalID nvarchar(15), DocumentReference nVarChar(255), Type nVarchar(50),
	AccountID int,FromDate datetime,ToDate datetime,DocRef int,DocType int,ColorInfoParam int,
	AccountName nvarchar(255),Debit decimal(18,6),Credit decimal(18,6),Balance nvarchar(50), DocumentBalance nVarChar(50), 
	Narration nvarchar(2000),ChequeInfo nvarchar(255),HighLight int)              
	Insert into #LEAFACCOUNT
 	exec sp_acc_rpt_account @fromdate,@todate,@parentid,@State,@TBType    
	Select count(*) from #LEAFACCOUNT
	Drop Table #LEAFACCOUNT
END              
ELSE IF @mode =@NEXTLEVEL              
BEGIN              
 	
	exec sp_acc_prn_Ledger_GetdrillCount @docref,@doctype,@Info             
END 


