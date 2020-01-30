Create Procedure Sp_TempTableUpldate_SPR_SystemSKU_ITC (  
@ReportID NVarchar(255),@WDCode NVarchar(255),@WDDest NVarchar(255),@SKU NVarchar(255),@Column NVarchar(255),@ColumnValue NVarchar(255))  
As  
Declare @Sql NVarchar(255)  
If Not Exists (Select * From #TempExistColumn1 Where ColumnName=@Column)  
Begin  
 --Dynamic column is not in the consolidation table  
 --So we have to add this dynamic column into the consolidation table  
 Set @Sql='Alter Table #TempConsolidate Add ' + @Column + ' Decimal(18,6)'  
 Exec (@Sql)  
 Insert Into #TempExistColumn1 (ColumnName) Values (@Column)   
End  
Else  
Begin  
 --The column already present in the consolidation table    
 --we simply update its value to this column using WDCode,WDDest and MarketSKU  
 Set @Sql='Update #TempConsolidate1 Set ' + @Column + ' = IsNull(' + @Column + ',0) + Cast(Cast(IsNull('+ @ColumnValue + ',0) as float) as Decimal(18,6)) Where'  
 Set @Sql=@Sql+' WDCode='''+ @WDCode + ''' And WDDest = ''' + @WDDest + ''' And MarketSKU = ''' + @SKU + ''' And CategoryID = ''' + @ReportID + ''''  
 Exec (@Sql)  
End  
