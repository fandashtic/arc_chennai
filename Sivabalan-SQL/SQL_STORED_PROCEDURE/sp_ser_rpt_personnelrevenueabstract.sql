CREATE procedure sp_ser_rpt_personnelrevenueabstract 
(@PersonnelName varchar(15), @FromDate datetime, @ToDate datetime)
as
Select --p.PersonnelID + Char(2) + Cast(@FromDate as nvarchar(12)) + Char(2) + Cast(@ToDate as nvarchar(12)) 'IDtoDetail', 
p.PersonnelID 'PersonnelID', p.PersonnelID 'PersonnelID', PersonnelName 'Personnel Name', 
Sum(IsNull(r.Price,0)) 'Amount', Sum((Case isNull(r.Price, -1) When -1 then 0 else 1 end)) 'No of Task' from PersonnelMaster p 
Left outer join 
(Select t.PersonnelID, t.TaskID, d.Price from JobCardtaskAllocation t --On p.PersonnelID = t.PersonnelID
Inner Join JobcardAbstract j On j.JobcardID = t.JobcardID 
Inner Join ServiceInvoiceAbstract a On a.JobCardID = j.JobcardID 
Inner Join ServiceInvoiceDetail d On a.ServiceInvoiceID = d.ServiceInvoiceID and 
d.Product_Code = t.Product_Code and d.Product_Specification1 = t.Product_Specification1 and 
t.TaskID = d.TaskID 
Where t.TaskStatus = 2 and d.Type = 2 and IsNull(d.Sparecode,'') = '' and 
((IsNull(a.status,0) & 192) <> 192) and ((IsNull(j.status,0) & 192) <> 192) and 
isNull(d.Price, 0) > 0 and 
(a.ServiceInvoiceDate between @fromdate and @todate)) r
On p.PersonnelID = r.PersonnelID 
Where p.PersonnelName Like @PersonnelName
Group by p.PersonnelID,p.PersonnelName 


