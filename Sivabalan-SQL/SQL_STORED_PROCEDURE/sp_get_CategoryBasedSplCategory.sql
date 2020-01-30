
Create Procedure sp_get_CategoryBasedSplCategory
                (@Special_Cat_Code INT)
As
Select CategoryID from Special_Cat_Product where Special_Cat_Code=@Special_Cat_Code



