CREATE Procedure sp_han_CollectionConfig
AS

Select 
(Select Top 1 Tool_Value From tblTools Where Tool_ID = 1) 'WriteOff_Validation',
(Select Top 1 Tool_Value From tblTools Where Tool_ID = 2) 'Coll_Disc_PymtDate_Validation',
(Select Top 1 Tool_Value From tblTools Where Tool_ID = 3) 'Allow_Coll_Fulladjust'


--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$ The List of Tool_ID Number Refere to which Option    $$--
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$ 1 : [WriteOff_Validation] 
--$$ 2 : [Coll_Disc_PymtDate_Validation] 
--$$ 3 : [Allow_Coll_Fulladjust] 
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$ List Format
--$$ ToolID : [Tool_Data] :: InDetail
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

