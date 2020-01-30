Create VIEW  [dbo].[V_EANNUMBER]
(Item_Code, Ean_Number)
AS

SELECT
	VI.Item_Code, I.EAN_NUMBER
FROM
	V_Item_Master VI, Items I
WHERE
	VI.Item_Code = I.Product_Code
	And IsNull(I.EAN_NUMBER, '') <> ''

