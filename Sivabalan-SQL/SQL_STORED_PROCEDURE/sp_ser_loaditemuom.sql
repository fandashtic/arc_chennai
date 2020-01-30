CREATE procedure [dbo].[sp_ser_loaditemuom](@Product_Code nvarchar(15))  
as  
Select IsNull(Items.UOM2,0) UOM2, IsNull(Items.UOM1,0) UOM1, IsNull(Items.UOM,0) UOM,
IsNull(c.Description,'') UOM2_Desc, IsNull(b.Description,'') UOM1_Desc,IsNull(a.Description,'') UOM0_Desc,  
IsNull(UOM2_Conversion,0) UOM2_Conversion, IsNull(UOM1_Conversion,0) UOM1_Conversion
From Items, UOM a, UOM b, UOM c    
Where Product_Code = @Product_Code   
And Items.UOM *= a.UOM   
And Items.UOM1 *= b.UOM And Items.UOM2 *= c.UOM
