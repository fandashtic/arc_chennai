CREATE Procedure FSU_GetFileDetails
As
Begin
Select distinct Filename as [File Name] from tbl_merp_fileinfo
where (filename like '%.exe' or filename like '%.dll')
And FileName Not In ('Microsoft.Office.Interop.Excel.dll', 'Microsoft.Vbe.Interop.dll', 'MigraDoc.DocumentObjectModel.dll', 'MigraDoc.Rendering.dll',
'MigraDoc.RtfRendering.dll', 'PdfSharp.Charting.dll', 'PdfSharp.dll', 'Interop.Excel.dll', 'office.dll')
order by Filename
End

