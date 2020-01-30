Create Procedure mERP_sp_get_ToolsConfig(@ToolID Int)
AS

Select Tool_Value From tblTools Where Tool_ID = @ToolID

--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$ The List of Tool_ID Number Refere to which Option    $$--
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$ 1 : [WriteOff_Validation] :: Used in Collection screen.
--$$ 2 : [Coll_Disc_PymtDate_Validation] :: Used in Collection screen while giving the additional discount.
--$$ 3 : [Coll_Disc_With_FullyAdjust] :: Used in Collection screen's fully adjustment working with additional discount.
--$$ 4 : [Compute_PTR_From_MarginUpdation] :: Used in GRNBill screen's PTR value Compute based on Margin updation.
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$ List Format
--$$ ToolID : [Tool_Data] :: InDetail
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
