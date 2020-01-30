Create Procedure mERP_sp_List_DSTraining_ExportList(@DSTrn_ID_List nVarchar(2000),@DSType_ID_List nVarchar(2000))
As
Begin
  --Declare @DSTrn_ID_List nVarchar(2000)
  --Set @DSTrn_ID_List = '%'
  Declare @tmpDSTrainingID Table(DSTrn_ID int)
  IF @DSTrn_ID_List =N'%'
    Insert into @tmpDSTrainingID Select DSTraining_ID From tbl_mERP_DSTraining Where DSTraining_Active = 1 
  Else
    Insert into @tmpDSTrainingID 
    Select DSTraining_ID From tbl_mERP_DSTraining Where DSTraining_ID in (Select * from dbo.sp_SplitIn2Rows(@DSTrn_ID_List,N','))

  --Declare @DSType_ID_List nVarchar(2000)
  --Set @DSType_ID_List = '%'
  Declare @tmpDSTypeID Table(DSType_ID int)
  IF @DSType_ID_List =N'%'
    Insert into @tmpDSTypeID 
    Select Distinct DSType_Mas.DSTypeID From DSType_Master DSType_Mas, DSType_Details DSType_Det
    Where DSType_Mas.Active = 1 and 
    DSType_Mas.DSTypeID = DSType_Det.DSTypeID
  Else
    Insert into @tmpDSTypeID 
    Select Distinct DSType_Mas.DSTypeID From DSType_Master DSType_Mas, DSType_Details DSType_Det
    Where DSType_Mas.Active = 1 and 
    DSType_Mas.DSTypeID in (Select * from dbo.sp_SplitIn2Rows(@DSType_ID_List,N','))

  Create Table #tmpData(
  DSTraining_Code nVarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
  DSTraining_Name nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  Facilitator nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  Town nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  PlannedDate DateTime,   
  ActualDate  DateTime,
  SalesMan_ID nVarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  SalesMan_Name nVarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  DSTypeValue nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
  Attended Bit,
  Score Decimal(18,6)
  )

  
  Insert into #tmpData
  --Select DSTAbs.ID, DsType.SalesmanID, DsType.DSTypeID
  Select DSTAbs.DSTraining_Code, DSTAbs.DSTraining_Name, IsNull(DSTDet.Facilitator,'') Facilitator, IsNull(DSTDet.Town,'') Town, 
  IsNull(DSTDet.PlannedDate,'') PlannedDate, IsNull(DSTDet.ActualDate,'') ActualDate, 
  Cast(SM.SalesManId as Varchar(10)), SM.SalesMan_Name, DS_Mas.DSTypeValue, IsNull(DSTDet.Attended,0) Attended, IsNull(DSTDet.Score,0) Score
  From tbl_mERP_DSTraining DSTAbs
  Left Outer Join tbl_mERP_DSTrainingDetail DSTDet On  DSTAbs.DSTraining_ID = DSTdet.DSTrainingID 
  Left Outer Join Salesman SM On  SM.SalesmanID = DSTdet.DSCode
  Inner Join DSType_Details DsType On SM.SalesmanID = DSType.SalesmanID
  Inner Join  DSType_Master DS_Mas On DS_Mas.DsTypeID = DSType.DSTypeID
  Inner Join @tmpDSTypeID tmpDSType On DS_Mas.DsTypeID = tmpDSType.DSType_ID
  Inner Join @tmpDSTrainingID tmpDSTrn On DSTAbs.DSTraining_ID = tmpDSTrn.DSTrn_ID
  Where  DS_Mas.DSTypeCtlPos = 1 and SM.Active = 1 and SM.CategoryMapping = 1 
  
  Select Count(*) From #tmpData

  Select DSTraining_Code, DSTraining_Name, Facilitator, Town, 
  Case PlannedDate When '' Then '' else Convert(nvarchar(10),PlannedDate,103) End PlannedDate, 
  Case PlannedDate When '' Then '' else Convert(nvarchar(10),ActualDate,103) End ActualDate, 
  SalesMan_ID, SalesMan_Name, DSTypeValue, Case IsNull(Attended,0) When 0 Then 'No' else 'Yes' End Attended, Score
  From #tmpData
  Order by DSTraining_Code, ActualDate, Facilitator, Town, DSTypeValue, Salesman_Name 

  Drop table #tmpData
End
