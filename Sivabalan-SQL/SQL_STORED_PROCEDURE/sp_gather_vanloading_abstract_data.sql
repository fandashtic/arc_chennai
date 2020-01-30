
create procedure sp_gather_vanloading_abstract_data (@START_DATE datetime,
						     @END_DATE datetime)
as
Select DocSerial, DocumentID, DocumentDate, Salesman.Salesman_Name, 
Beat.Description, DocumentValue, Van.Van_Number, Status 
From VanStatementAbstract, Salesman, Van, Beat
Where VanStatementAbstract.SalesmanID = Salesman.SalesmanID and
VanStatementAbstract.VanID = Van And
VanStatementAbstract.BeatID = Beat.BeatID

