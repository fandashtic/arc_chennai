CREATE  VIEW   [V_Tax] 
([Tax_ID],[LST_Percentage],[LST_Component_Percentage],[LST_Component_Name],[CST_Percentage],[CST_Component_Percentage],[CST_Component_Name], [Active])
AS
SELECT 	Tax_Code,Percentage,'LST_Component_Percentage'=(Select Tax_Percentage from TaxComponents where LST_Flag=1 and Tax_code=Tax.Tax_Code) ,
	'LST_Component_Name'=(Select TaxComponent_Desc  from TaxComponents,TaxComponentDetail where LST_Flag=1 and Tax_code=Tax.Tax_Code and TaxComponents.TaxComponent_Code=TaxComponentDetail.TaxComponent_Code),  
         CST_Percentage,'CST_Component_Percentage'=(Select Tax_Percentage from TaxComponents where LST_Flag=0 and Tax_code=Tax.Tax_Code) ,
	'CST_Component_Name'=(Select TaxComponent_Desc  from TaxComponents,TaxComponentDetail where LST_Flag=0 and Tax_code=Tax.Tax_Code and TaxComponents.TaxComponent_Code=TaxComponentDetail.TaxComponent_Code),Active    
from 	Tax
