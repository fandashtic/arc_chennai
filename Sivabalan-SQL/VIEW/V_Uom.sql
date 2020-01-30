CREATE  VIEW   [V_Uom] 
([UOMID],[UOMName],Active)
AS
SELECT
Uom,Description,Active
from UOM
