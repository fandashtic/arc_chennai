Select * into CustomerCreditLimit_Bak_11Feb2020 From CustomerCreditLimit
GO

Declare @CreditTerm as Table (id Int Identity (1,1), CreditID int)
Insert into	@CreditTerm(CreditID) select distinct Value from CreditTerm Where Active = 1 And Value in (0, 7, 15, 21)

Declare @Customer as Table (id Int Identity (1,1), CustomerID Nvarchar(255), GroupName Nvarchar(255))
Insert into @Customer(CustomerID, GroupName)
Select 'ARCBAK199', 'GR1A' UNION ALL
Select 'ARCBAK199', 'GR1B' UNION ALL
Select 'ARCBAK199', 'GR1C' UNION ALL
Select 'ARCBAK199', 'GR2' UNION ALL
Select 'ARCBAK199', 'GR4' UNION ALL
Select 'ARCCM1050', 'GR1A' UNION ALL
Select 'ARCCM1050', 'GR1B' UNION ALL
Select 'ARCCM1050', 'GR1C' UNION ALL
Select 'ARCCM1050', 'GR2' UNION ALL
Select 'ARCCM1050', 'GR4' UNION ALL
Select 'ARCCM1051', 'GR1A' UNION ALL
Select 'ARCCM1051', 'GR1B' UNION ALL
Select 'ARCCM1051', 'GR1C' UNION ALL
Select 'ARCCM1051', 'GR2' UNION ALL
Select 'ARCCM1051', 'GR4' UNION ALL
Select 'ARCCM1052', 'GR1A' UNION ALL
Select 'ARCCM1052', 'GR1B' UNION ALL
Select 'ARCCM1052', 'GR1C' UNION ALL
Select 'ARCCM1052', 'GR2' UNION ALL
Select 'ARCCM1052', 'GR4' UNION ALL
Select 'ARCCM1053', 'GR1A' UNION ALL
Select 'ARCCM1053', 'GR1B' UNION ALL
Select 'ARCCM1053', 'GR1C' UNION ALL
Select 'ARCCM1053', 'GR2' UNION ALL
Select 'ARCCM1053', 'GR4' UNION ALL
Select 'ARCCM1056', 'GR1A' UNION ALL
Select 'ARCCM1056', 'GR1B' UNION ALL
Select 'ARCCM1056', 'GR1C' UNION ALL
Select 'ARCCM1056', 'GR2' UNION ALL
Select 'ARCCM1056', 'GR4' UNION ALL
Select 'ARCCM1057', 'GR1A' UNION ALL
Select 'ARCCM1057', 'GR1B' UNION ALL
Select 'ARCCM1057', 'GR1C' UNION ALL
Select 'ARCCM1057', 'GR2' UNION ALL
Select 'ARCCM1057', 'GR4' UNION ALL
Select 'ARCCM1058', 'GR1A' UNION ALL
Select 'ARCCM1058', 'GR1B' UNION ALL
Select 'ARCCM1058', 'GR1C' UNION ALL
Select 'ARCCM1058', 'GR2' UNION ALL
Select 'ARCCM1058', 'GR4' UNION ALL
Select 'ARCCM1059', 'GR1A' UNION ALL
Select 'ARCCM1059', 'GR1B' UNION ALL
Select 'ARCCM1059', 'GR1C' UNION ALL
Select 'ARCCM1059', 'GR2' UNION ALL
Select 'ARCCM1059', 'GR4' UNION ALL
Select 'ARCCM376', 'GR1A' UNION ALL
Select 'ARCCM376', 'GR1B' UNION ALL
Select 'ARCCM376', 'GR1C' UNION ALL
Select 'ARCCM376', 'GR2' UNION ALL
Select 'ARCCM376', 'GR4' UNION ALL
Select 'ARCCM377', 'GR1A' UNION ALL
Select 'ARCCM377', 'GR1B' UNION ALL
Select 'ARCCM377', 'GR1C' UNION ALL
Select 'ARCCM377', 'GR2' UNION ALL
Select 'ARCCM377', 'GR4' UNION ALL
Select 'ARCDFCF16', 'GR1A' UNION ALL
Select 'ARCDFCF16', 'GR1B' UNION ALL
Select 'ARCDFCF16', 'GR1C' UNION ALL
Select 'ARCDFCF16', 'GR2' UNION ALL
Select 'ARCDFCF16', 'GR4' UNION ALL
Select 'ARCDFCF18', 'GR1A' UNION ALL
Select 'ARCDFCF18', 'GR1B' UNION ALL
Select 'ARCDFCF18', 'GR1C' UNION ALL
Select 'ARCDFCF18', 'GR2' UNION ALL
Select 'ARCDFCF18', 'GR4' UNION ALL
Select 'ARCDFCF19', 'GR1A' UNION ALL
Select 'ARCDFCF19', 'GR1B' UNION ALL
Select 'ARCDFCF19', 'GR1C' UNION ALL
Select 'ARCDFCF19', 'GR2' UNION ALL
Select 'ARCDFCF19', 'GR4' UNION ALL
Select 'ARCDFCF20', 'GR1A' UNION ALL
Select 'ARCDFCF20', 'GR1B' UNION ALL
Select 'ARCDFCF20', 'GR1C' UNION ALL
Select 'ARCDFCF20', 'GR2' UNION ALL
Select 'ARCDFCF20', 'GR4' UNION ALL
Select 'ARCDFCF21', 'GR1A' UNION ALL
Select 'ARCDFCF21', 'GR1B' UNION ALL
Select 'ARCDFCF21', 'GR1C' UNION ALL
Select 'ARCDFCF21', 'GR2' UNION ALL
Select 'ARCDFCF21', 'GR4' UNION ALL
Select 'ARCDFCF22', 'GR1A' UNION ALL
Select 'ARCDFCF22', 'GR1B' UNION ALL
Select 'ARCDFCF22', 'GR1C' UNION ALL
Select 'ARCDFCF22', 'GR2' UNION ALL
Select 'ARCDFCF22', 'GR4' UNION ALL
Select 'ARCDFCF23', 'GR1A' UNION ALL
Select 'ARCDFCF23', 'GR1B' UNION ALL
Select 'ARCDFCF23', 'GR1C' UNION ALL
Select 'ARCDFCF23', 'GR2' UNION ALL
Select 'ARCDFCF23', 'GR4' UNION ALL
Select 'ARCDFCF25', 'GR1A' UNION ALL
Select 'ARCDFCF25', 'GR1B' UNION ALL
Select 'ARCDFCF25', 'GR1C' UNION ALL
Select 'ARCDFCF25', 'GR2' UNION ALL
Select 'ARCDFCF25', 'GR4' UNION ALL
Select 'ARCDFCF26', 'GR1A' UNION ALL
Select 'ARCDFCF26', 'GR1B' UNION ALL
Select 'ARCDFCF26', 'GR1C' UNION ALL
Select 'ARCDFCF26', 'GR2' UNION ALL
Select 'ARCDFCF26', 'GR4' UNION ALL
Select 'ARCDFCF27', 'GR1A' UNION ALL
Select 'ARCDFCF27', 'GR1B' UNION ALL
Select 'ARCDFCF27', 'GR1C' UNION ALL
Select 'ARCDFCF27', 'GR2' UNION ALL
Select 'ARCDFCF27', 'GR4' UNION ALL
Select 'ARCDFCF28', 'GR1A' UNION ALL
Select 'ARCDFCF28', 'GR1B' UNION ALL
Select 'ARCDFCF28', 'GR1C' UNION ALL
Select 'ARCDFCF28', 'GR2' UNION ALL
Select 'ARCDFCF28', 'GR4' UNION ALL
Select 'ARCDFCF29', 'GR1A' UNION ALL
Select 'ARCDFCF29', 'GR1B' UNION ALL
Select 'ARCDFCF29', 'GR1C' UNION ALL
Select 'ARCDFCF29', 'GR2' UNION ALL
Select 'ARCDFCF29', 'GR4' UNION ALL
Select 'ARCDFCF30', 'GR1A' UNION ALL
Select 'ARCDFCF30', 'GR1B' UNION ALL
Select 'ARCDFCF30', 'GR1C' UNION ALL
Select 'ARCDFCF30', 'GR2' UNION ALL
Select 'ARCDFCF30', 'GR4' UNION ALL
Select 'ARCDFCF31', 'GR1A' UNION ALL
Select 'ARCDFCF31', 'GR1B' UNION ALL
Select 'ARCDFCF31', 'GR1C' UNION ALL
Select 'ARCDFCF31', 'GR2' UNION ALL
Select 'ARCDFCF31', 'GR4' UNION ALL
Select 'ARCDFCF32', 'GR1A' UNION ALL
Select 'ARCDFCF32', 'GR1B' UNION ALL
Select 'ARCDFCF32', 'GR1C' UNION ALL
Select 'ARCDFCF32', 'GR2' UNION ALL
Select 'ARCDFCF32', 'GR4' UNION ALL
Select 'ARCDFCF33', 'GR1A' UNION ALL
Select 'ARCDFCF33', 'GR1B' UNION ALL
Select 'ARCDFCF33', 'GR1C' UNION ALL
Select 'ARCDFCF33', 'GR2' UNION ALL
Select 'ARCDFCF33', 'GR4' UNION ALL
Select 'ARCDFCF34', 'GR1A' UNION ALL
Select 'ARCDFCF34', 'GR1B' UNION ALL
Select 'ARCDFCF34', 'GR1C' UNION ALL
Select 'ARCDFCF34', 'GR2' UNION ALL
Select 'ARCDFCF34', 'GR4' UNION ALL
Select 'ARCDFCF36', 'GR1A' UNION ALL
Select 'ARCDFCF36', 'GR1B' UNION ALL
Select 'ARCDFCF36', 'GR1C' UNION ALL
Select 'ARCDFCF36', 'GR2' UNION ALL
Select 'ARCDFCF36', 'GR4' UNION ALL
Select 'ARCDFCF38', 'GR1A' UNION ALL
Select 'ARCDFCF38', 'GR1B' UNION ALL
Select 'ARCDFCF38', 'GR1C' UNION ALL
Select 'ARCDFCF38', 'GR2' UNION ALL
Select 'ARCDFCF38', 'GR4' UNION ALL
Select 'ARCDFCF39', 'GR1A' UNION ALL
Select 'ARCDFCF39', 'GR1B' UNION ALL
Select 'ARCDFCF39', 'GR1C' UNION ALL
Select 'ARCDFCF39', 'GR2' UNION ALL
Select 'ARCDFCF39', 'GR4' UNION ALL
Select 'ARCGR1823', 'GR1A' UNION ALL
Select 'ARCGR1823', 'GR1B' UNION ALL
Select 'ARCGR1823', 'GR1C' UNION ALL
Select 'ARCGR1823', 'GR2' UNION ALL
Select 'ARCGR1823', 'GR4' UNION ALL
Select 'ARCGR1999', 'GR1A' UNION ALL
Select 'ARCGR1999', 'GR1B' UNION ALL
Select 'ARCGR1999', 'GR1C' UNION ALL
Select 'ARCGR1999', 'GR2' UNION ALL
Select 'ARCGR1999', 'GR4' UNION ALL
Select 'ARCGR2004', 'GR1A' UNION ALL
Select 'ARCGR2004', 'GR1B' UNION ALL
Select 'ARCGR2004', 'GR1C' UNION ALL
Select 'ARCGR2004', 'GR2' UNION ALL
Select 'ARCGR2004', 'GR4' UNION ALL
Select 'ARCGR2006', 'GR1A' UNION ALL
Select 'ARCGR2006', 'GR1B' UNION ALL
Select 'ARCGR2006', 'GR1C' UNION ALL
Select 'ARCGR2006', 'GR2' UNION ALL
Select 'ARCGR2006', 'GR4' UNION ALL
Select 'ARCGR2008', 'GR1A' UNION ALL
Select 'ARCGR2008', 'GR1B' UNION ALL
Select 'ARCGR2008', 'GR1C' UNION ALL
Select 'ARCGR2008', 'GR2' UNION ALL
Select 'ARCGR2008', 'GR4' UNION ALL
Select 'ARCGR2010', 'GR1A' UNION ALL
Select 'ARCGR2010', 'GR1B' UNION ALL
Select 'ARCGR2010', 'GR1C' UNION ALL
Select 'ARCGR2010', 'GR2' UNION ALL
Select 'ARCGR2010', 'GR4' UNION ALL
Select 'ARCGR2015', 'GR1A' UNION ALL
Select 'ARCGR2015', 'GR1B' UNION ALL
Select 'ARCGR2015', 'GR1C' UNION ALL
Select 'ARCGR2015', 'GR2' UNION ALL
Select 'ARCGR2015', 'GR4' UNION ALL
Select 'ARCGR2032', 'GR1A' UNION ALL
Select 'ARCGR2032', 'GR1B' UNION ALL
Select 'ARCGR2032', 'GR1C' UNION ALL
Select 'ARCGR2032', 'GR2' UNION ALL
Select 'ARCGR2032', 'GR4' UNION ALL
Select 'ARCGR2050', 'GR1A' UNION ALL
Select 'ARCGR2050', 'GR1B' UNION ALL
Select 'ARCGR2050', 'GR1C' UNION ALL
Select 'ARCGR2050', 'GR2' UNION ALL
Select 'ARCGR2050', 'GR4' UNION ALL
Select 'ARCGR2051', 'GR1A' UNION ALL
Select 'ARCGR2051', 'GR1B' UNION ALL
Select 'ARCGR2051', 'GR1C' UNION ALL
Select 'ARCGR2051', 'GR2' UNION ALL
Select 'ARCGR2051', 'GR4' UNION ALL
Select 'ARCGR2052', 'GR1A' UNION ALL
Select 'ARCGR2052', 'GR1B' UNION ALL
Select 'ARCGR2052', 'GR1C' UNION ALL
Select 'ARCGR2052', 'GR2' UNION ALL
Select 'ARCGR2052', 'GR4' UNION ALL
Select 'ARCGR2053', 'GR1A' UNION ALL
Select 'ARCGR2053', 'GR1B' UNION ALL
Select 'ARCGR2053', 'GR1C' UNION ALL
Select 'ARCGR2053', 'GR2' UNION ALL
Select 'ARCGR2053', 'GR4' UNION ALL
Select 'ARCGR2054', 'GR1A' UNION ALL
Select 'ARCGR2054', 'GR1B' UNION ALL
Select 'ARCGR2054', 'GR1C' UNION ALL
Select 'ARCGR2054', 'GR2' UNION ALL
Select 'ARCGR2054', 'GR4' UNION ALL
Select 'ARCGR2055', 'GR1A' UNION ALL
Select 'ARCGR2055', 'GR1B' UNION ALL
Select 'ARCGR2055', 'GR1C' UNION ALL
Select 'ARCGR2055', 'GR2' UNION ALL
Select 'ARCGR2055', 'GR4' UNION ALL
Select 'ARCGR2056', 'GR1A' UNION ALL
Select 'ARCGR2056', 'GR1B' UNION ALL
Select 'ARCGR2056', 'GR1C' UNION ALL
Select 'ARCGR2056', 'GR2' UNION ALL
Select 'ARCGR2056', 'GR4' UNION ALL
Select 'ARCGR2057', 'GR1A' UNION ALL
Select 'ARCGR2057', 'GR1B' UNION ALL
Select 'ARCGR2057', 'GR1C' UNION ALL
Select 'ARCGR2057', 'GR2' UNION ALL
Select 'ARCGR2057', 'GR4' UNION ALL
Select 'ARCGR2058', 'GR1A' UNION ALL
Select 'ARCGR2058', 'GR1B' UNION ALL
Select 'ARCGR2058', 'GR1C' UNION ALL
Select 'ARCGR2058', 'GR2' UNION ALL
Select 'ARCGR2058', 'GR4' UNION ALL
Select 'ARCGR2059', 'GR1A' UNION ALL
Select 'ARCGR2059', 'GR1B' UNION ALL
Select 'ARCGR2059', 'GR1C' UNION ALL
Select 'ARCGR2059', 'GR2' UNION ALL
Select 'ARCGR2059', 'GR4' UNION ALL
Select 'ARCGR2060', 'GR1A' UNION ALL
Select 'ARCGR2060', 'GR1B' UNION ALL
Select 'ARCGR2060', 'GR1C' UNION ALL
Select 'ARCGR2060', 'GR2' UNION ALL
Select 'ARCGR2060', 'GR4' UNION ALL
Select 'ARCGR2061', 'GR1A' UNION ALL
Select 'ARCGR2061', 'GR1B' UNION ALL
Select 'ARCGR2061', 'GR1C' UNION ALL
Select 'ARCGR2061', 'GR2' UNION ALL
Select 'ARCGR2061', 'GR4' UNION ALL
Select 'ARCGR2062', 'GR1A' UNION ALL
Select 'ARCGR2062', 'GR1B' UNION ALL
Select 'ARCGR2062', 'GR1C' UNION ALL
Select 'ARCGR2062', 'GR2' UNION ALL
Select 'ARCGR2062', 'GR4' UNION ALL
Select 'ARCGR2436', 'GR1A' UNION ALL
Select 'ARCGR2436', 'GR1B' UNION ALL
Select 'ARCGR2436', 'GR1C' UNION ALL
Select 'ARCGR2436', 'GR2' UNION ALL
Select 'ARCGR2436', 'GR4' UNION ALL
Select 'ARCGR2625', 'GR1A' UNION ALL
Select 'ARCGR2625', 'GR1B' UNION ALL
Select 'ARCGR2625', 'GR1C' UNION ALL
Select 'ARCGR2625', 'GR2' UNION ALL
Select 'ARCGR2625', 'GR4' UNION ALL
Select 'ARCGR2726', 'GR1A' UNION ALL
Select 'ARCGR2726', 'GR1B' UNION ALL
Select 'ARCGR2726', 'GR1C' UNION ALL
Select 'ARCGR2726', 'GR2' UNION ALL
Select 'ARCGR2726', 'GR4' UNION ALL
Select 'ARCGR3010', 'GR1A' UNION ALL
Select 'ARCGR3010', 'GR1B' UNION ALL
Select 'ARCGR3010', 'GR1C' UNION ALL
Select 'ARCGR3010', 'GR2' UNION ALL
Select 'ARCGR3010', 'GR4' UNION ALL
Select 'ARCGR4005', 'GR1A' UNION ALL
Select 'ARCGR4005', 'GR1B' UNION ALL
Select 'ARCGR4005', 'GR1C' UNION ALL
Select 'ARCGR4005', 'GR2' UNION ALL
Select 'ARCGR4005', 'GR4' UNION ALL
Select 'ARCISS1000', 'GR1A' UNION ALL
Select 'ARCISS1000', 'GR1B' UNION ALL
Select 'ARCISS1000', 'GR1C' UNION ALL
Select 'ARCISS1000', 'GR2' UNION ALL
Select 'ARCISS1000', 'GR4' UNION ALL
Select 'ARCISS1005', 'GR1A' UNION ALL
Select 'ARCISS1005', 'GR1B' UNION ALL
Select 'ARCISS1005', 'GR1C' UNION ALL
Select 'ARCISS1005', 'GR2' UNION ALL
Select 'ARCISS1005', 'GR4' UNION ALL
Select 'ARCISS1171', 'GR1A' UNION ALL
Select 'ARCISS1171', 'GR1B' UNION ALL
Select 'ARCISS1171', 'GR1C' UNION ALL
Select 'ARCISS1171', 'GR2' UNION ALL
Select 'ARCISS1171', 'GR4' UNION ALL
Select 'ARCISS209', 'GR1A' UNION ALL
Select 'ARCISS209', 'GR1B' UNION ALL
Select 'ARCISS209', 'GR1C' UNION ALL
Select 'ARCISS209', 'GR2' UNION ALL
Select 'ARCISS209', 'GR4' UNION ALL
Select 'ARCISS211', 'GR1A' UNION ALL
Select 'ARCISS211', 'GR1B' UNION ALL
Select 'ARCISS211', 'GR1C' UNION ALL
Select 'ARCISS211', 'GR2' UNION ALL
Select 'ARCISS211', 'GR4' UNION ALL
Select 'ARC-NONCIG-009', 'GR1A' UNION ALL
Select 'ARC-NONCIG-009', 'GR1B' UNION ALL
Select 'ARC-NONCIG-009', 'GR1C' UNION ALL
Select 'ARC-NONCIG-009', 'GR2' UNION ALL
Select 'ARC-NONCIG-009', 'GR4' UNION ALL
Select 'ARC-NONCIG-010', 'GR1A' UNION ALL
Select 'ARC-NONCIG-010', 'GR1B' UNION ALL
Select 'ARC-NONCIG-010', 'GR1C' UNION ALL
Select 'ARC-NONCIG-010', 'GR2' UNION ALL
Select 'ARC-NONCIG-010', 'GR4' UNION ALL
Select 'ARC-NONCIG-011', 'GR1A' UNION ALL
Select 'ARC-NONCIG-011', 'GR1B' UNION ALL
Select 'ARC-NONCIG-011', 'GR1C' UNION ALL
Select 'ARC-NONCIG-011', 'GR2' UNION ALL
Select 'ARC-NONCIG-011', 'GR4' UNION ALL
Select 'ARC-NONCIG-012', 'GR1A' UNION ALL
Select 'ARC-NONCIG-012', 'GR1B' UNION ALL
Select 'ARC-NONCIG-012', 'GR1C' UNION ALL
Select 'ARC-NONCIG-012', 'GR2' UNION ALL
Select 'ARC-NONCIG-012', 'GR4' UNION ALL
Select 'ARC-NONCIG-013', 'GR1A' UNION ALL
Select 'ARC-NONCIG-013', 'GR1B' UNION ALL
Select 'ARC-NONCIG-013', 'GR1C' UNION ALL
Select 'ARC-NONCIG-013', 'GR2' UNION ALL
Select 'ARC-NONCIG-013', 'GR4' UNION ALL
Select 'ARC-NONCIG-014', 'GR1A' UNION ALL
Select 'ARC-NONCIG-014', 'GR1B' UNION ALL
Select 'ARC-NONCIG-014', 'GR1C' UNION ALL
Select 'ARC-NONCIG-014', 'GR2' UNION ALL
Select 'ARC-NONCIG-014', 'GR4' UNION ALL
Select 'ARC-NONCIG-015', 'GR1A' UNION ALL
Select 'ARC-NONCIG-015', 'GR1B' UNION ALL
Select 'ARC-NONCIG-015', 'GR1C' UNION ALL
Select 'ARC-NONCIG-015', 'GR2' UNION ALL
Select 'ARC-NONCIG-015', 'GR4' UNION ALL
Select 'ARC-NONCIG-016', 'GR1A' UNION ALL
Select 'ARC-NONCIG-016', 'GR1B' UNION ALL
Select 'ARC-NONCIG-016', 'GR1C' UNION ALL
Select 'ARC-NONCIG-016', 'GR2' UNION ALL
Select 'ARC-NONCIG-016', 'GR4' UNION ALL
Select 'ARC-NONCIG-017', 'GR1A' UNION ALL
Select 'ARC-NONCIG-017', 'GR1B' UNION ALL
Select 'ARC-NONCIG-017', 'GR1C' UNION ALL
Select 'ARC-NONCIG-017', 'GR2' UNION ALL
Select 'ARC-NONCIG-017', 'GR4' UNION ALL
Select 'ARC-NONCIG-018', 'GR1A' UNION ALL
Select 'ARC-NONCIG-018', 'GR1B' UNION ALL
Select 'ARC-NONCIG-018', 'GR1C' UNION ALL
Select 'ARC-NONCIG-018', 'GR2' UNION ALL
Select 'ARC-NONCIG-018', 'GR4' UNION ALL
Select 'ARC-NONCIG-019', 'GR1A' UNION ALL
Select 'ARC-NONCIG-019', 'GR1B' UNION ALL
Select 'ARC-NONCIG-019', 'GR1C' UNION ALL
Select 'ARC-NONCIG-019', 'GR2' UNION ALL
Select 'ARC-NONCIG-019', 'GR4' UNION ALL
Select 'ARC-NONCIG-020', 'GR1A' UNION ALL
Select 'ARC-NONCIG-020', 'GR1B' UNION ALL
Select 'ARC-NONCIG-020', 'GR1C' UNION ALL
Select 'ARC-NONCIG-020', 'GR2' UNION ALL
Select 'ARC-NONCIG-020', 'GR4' UNION ALL
Select 'ARC-NONCIG-021', 'GR1A' UNION ALL
Select 'ARC-NONCIG-021', 'GR1B' UNION ALL
Select 'ARC-NONCIG-021', 'GR1C' UNION ALL
Select 'ARC-NONCIG-021', 'GR2' UNION ALL
Select 'ARC-NONCIG-021', 'GR4' UNION ALL
Select 'ARC-NONCIG-022', 'GR1A' UNION ALL
Select 'ARC-NONCIG-022', 'GR1B' UNION ALL
Select 'ARC-NONCIG-022', 'GR1C' UNION ALL
Select 'ARC-NONCIG-022', 'GR2' UNION ALL
Select 'ARC-NONCIG-022', 'GR4' UNION ALL
Select 'ARC-NONCIG-023', 'GR1A' UNION ALL
Select 'ARC-NONCIG-023', 'GR1B' UNION ALL
Select 'ARC-NONCIG-023', 'GR1C' UNION ALL
Select 'ARC-NONCIG-023', 'GR2' UNION ALL
Select 'ARC-NONCIG-023', 'GR4' UNION ALL
Select 'ARC-NONCIG-024', 'GR1A' UNION ALL
Select 'ARC-NONCIG-024', 'GR1B' UNION ALL
Select 'ARC-NONCIG-024', 'GR1C' UNION ALL
Select 'ARC-NONCIG-024', 'GR2' UNION ALL
Select 'ARC-NONCIG-024', 'GR4' UNION ALL
Select 'ARC-NONCIG-025', 'GR1A' UNION ALL
Select 'ARC-NONCIG-025', 'GR1B' UNION ALL
Select 'ARC-NONCIG-025', 'GR1C' UNION ALL
Select 'ARC-NONCIG-025', 'GR2' UNION ALL
Select 'ARC-NONCIG-025', 'GR4' UNION ALL
Select 'ARC-NONCIG-026', 'GR1A' UNION ALL
Select 'ARC-NONCIG-026', 'GR1B' UNION ALL
Select 'ARC-NONCIG-026', 'GR1C' UNION ALL
Select 'ARC-NONCIG-026', 'GR2' UNION ALL
Select 'ARC-NONCIG-026', 'GR4' UNION ALL
Select 'ARC-NONCIG-027', 'GR1A' UNION ALL
Select 'ARC-NONCIG-027', 'GR1B' UNION ALL
Select 'ARC-NONCIG-027', 'GR1C' UNION ALL
Select 'ARC-NONCIG-027', 'GR2' UNION ALL
Select 'ARC-NONCIG-027', 'GR4' UNION ALL
Select 'ARC-NONCIG-028', 'GR1A' UNION ALL
Select 'ARC-NONCIG-028', 'GR1B' UNION ALL
Select 'ARC-NONCIG-028', 'GR1C' UNION ALL
Select 'ARC-NONCIG-028', 'GR2' UNION ALL
Select 'ARC-NONCIG-028', 'GR4' UNION ALL
Select 'ARC-NONCIG-029', 'GR1A' UNION ALL
Select 'ARC-NONCIG-029', 'GR1B' UNION ALL
Select 'ARC-NONCIG-029', 'GR1C' UNION ALL
Select 'ARC-NONCIG-029', 'GR2' UNION ALL
Select 'ARC-NONCIG-029', 'GR4' UNION ALL
Select 'ARC-NONCIG-030', 'GR1A' UNION ALL
Select 'ARC-NONCIG-030', 'GR1B' UNION ALL
Select 'ARC-NONCIG-030', 'GR1C' UNION ALL
Select 'ARC-NONCIG-030', 'GR2' UNION ALL
Select 'ARC-NONCIG-030', 'GR4' UNION ALL
Select 'ARC-NONCIG-031', 'GR1A' UNION ALL
Select 'ARC-NONCIG-031', 'GR1B' UNION ALL
Select 'ARC-NONCIG-031', 'GR1C' UNION ALL
Select 'ARC-NONCIG-031', 'GR2' UNION ALL
Select 'ARC-NONCIG-031', 'GR4' UNION ALL
Select 'ARC-NONCIG-032', 'GR1A' UNION ALL
Select 'ARC-NONCIG-032', 'GR1B' UNION ALL
Select 'ARC-NONCIG-032', 'GR1C' UNION ALL
Select 'ARC-NONCIG-032', 'GR2' UNION ALL
Select 'ARC-NONCIG-032', 'GR4' UNION ALL
Select 'ARC-NONCIG-033', 'GR1A' UNION ALL
Select 'ARC-NONCIG-033', 'GR1B' UNION ALL
Select 'ARC-NONCIG-033', 'GR1C' UNION ALL
Select 'ARC-NONCIG-033', 'GR2' UNION ALL
Select 'ARC-NONCIG-033', 'GR4' UNION ALL
Select 'ARC-NONCIG-034', 'GR1A' UNION ALL
Select 'ARC-NONCIG-034', 'GR1B' UNION ALL
Select 'ARC-NONCIG-034', 'GR1C' UNION ALL
Select 'ARC-NONCIG-034', 'GR2' UNION ALL
Select 'ARC-NONCIG-034', 'GR4' UNION ALL
Select 'ARC-NONCIG-035', 'GR1A' UNION ALL
Select 'ARC-NONCIG-035', 'GR1B' UNION ALL
Select 'ARC-NONCIG-035', 'GR1C' UNION ALL
Select 'ARC-NONCIG-035', 'GR2' UNION ALL
Select 'ARC-NONCIG-035', 'GR4' UNION ALL
Select 'ARC-NONCIG-036', 'GR1A' UNION ALL
Select 'ARC-NONCIG-036', 'GR1B' UNION ALL
Select 'ARC-NONCIG-036', 'GR1C' UNION ALL
Select 'ARC-NONCIG-036', 'GR2' UNION ALL
Select 'ARC-NONCIG-036', 'GR4' UNION ALL
Select 'ARC-NONCIG-037', 'GR1A' UNION ALL
Select 'ARC-NONCIG-037', 'GR1B' UNION ALL
Select 'ARC-NONCIG-037', 'GR1C' UNION ALL
Select 'ARC-NONCIG-037', 'GR2' UNION ALL
Select 'ARC-NONCIG-037', 'GR4' UNION ALL
Select 'ARC-NONCIG-038', 'GR1A' UNION ALL
Select 'ARC-NONCIG-038', 'GR1B' UNION ALL
Select 'ARC-NONCIG-038', 'GR1C' UNION ALL
Select 'ARC-NONCIG-038', 'GR2' UNION ALL
Select 'ARC-NONCIG-038', 'GR4' UNION ALL
Select 'ARC-NONCIG-039', 'GR1A' UNION ALL
Select 'ARC-NONCIG-039', 'GR1B' UNION ALL
Select 'ARC-NONCIG-039', 'GR1C' UNION ALL
Select 'ARC-NONCIG-039', 'GR2' UNION ALL
Select 'ARC-NONCIG-039', 'GR4' UNION ALL
Select 'ARC-NONCIG-040', 'GR1A' UNION ALL
Select 'ARC-NONCIG-040', 'GR1B' UNION ALL
Select 'ARC-NONCIG-040', 'GR1C' UNION ALL
Select 'ARC-NONCIG-040', 'GR2' UNION ALL
Select 'ARC-NONCIG-040', 'GR4' UNION ALL
Select 'ARC-NONCIG-041', 'GR1A' UNION ALL
Select 'ARC-NONCIG-041', 'GR1B' UNION ALL
Select 'ARC-NONCIG-041', 'GR1C' UNION ALL
Select 'ARC-NONCIG-041', 'GR2' UNION ALL
Select 'ARC-NONCIG-041', 'GR4' UNION ALL
Select 'ARC-NONCIG-042', 'GR1A' UNION ALL
Select 'ARC-NONCIG-042', 'GR1B' UNION ALL
Select 'ARC-NONCIG-042', 'GR1C' UNION ALL
Select 'ARC-NONCIG-042', 'GR2' UNION ALL
Select 'ARC-NONCIG-042', 'GR4' UNION ALL
Select 'ARC-NONGIG-001', 'GR1A' UNION ALL
Select 'ARC-NONGIG-001', 'GR1B' UNION ALL
Select 'ARC-NONGIG-001', 'GR1C' UNION ALL
Select 'ARC-NONGIG-001', 'GR2' UNION ALL
Select 'ARC-NONGIG-001', 'GR4' UNION ALL
Select 'ARC-NONGIG-002', 'GR1A' UNION ALL
Select 'ARC-NONGIG-002', 'GR1B' UNION ALL
Select 'ARC-NONGIG-002', 'GR1C' UNION ALL
Select 'ARC-NONGIG-002', 'GR2' UNION ALL
Select 'ARC-NONGIG-002', 'GR4' UNION ALL
Select 'ARC-NONGIG-003', 'GR1A' UNION ALL
Select 'ARC-NONGIG-003', 'GR1B' UNION ALL
Select 'ARC-NONGIG-003', 'GR1C' UNION ALL
Select 'ARC-NONGIG-003', 'GR2' UNION ALL
Select 'ARC-NONGIG-003', 'GR4' UNION ALL
Select 'ARC-NONGIG-004', 'GR1A' UNION ALL
Select 'ARC-NONGIG-004', 'GR1B' UNION ALL
Select 'ARC-NONGIG-004', 'GR1C' UNION ALL
Select 'ARC-NONGIG-004', 'GR2' UNION ALL
Select 'ARC-NONGIG-004', 'GR4' UNION ALL
Select 'ARC-NONGIG-005', 'GR1A' UNION ALL
Select 'ARC-NONGIG-005', 'GR1B' UNION ALL
Select 'ARC-NONGIG-005', 'GR1C' UNION ALL
Select 'ARC-NONGIG-005', 'GR2' UNION ALL
Select 'ARC-NONGIG-005', 'GR4' UNION ALL
Select 'ARC-NONGIG-006', 'GR1A' UNION ALL
Select 'ARC-NONGIG-006', 'GR1B' UNION ALL
Select 'ARC-NONGIG-006', 'GR1C' UNION ALL
Select 'ARC-NONGIG-006', 'GR2' UNION ALL
Select 'ARC-NONGIG-006', 'GR4' UNION ALL
Select 'ARC-NONGIG-007', 'GR1A' UNION ALL
Select 'ARC-NONGIG-007', 'GR1B' UNION ALL
Select 'ARC-NONGIG-007', 'GR1C' UNION ALL
Select 'ARC-NONGIG-007', 'GR2' UNION ALL
Select 'ARC-NONGIG-007', 'GR4' UNION ALL
Select 'ARC-NONGIG-008', 'GR1A' UNION ALL
Select 'ARC-NONGIG-008', 'GR1B' UNION ALL
Select 'ARC-NONGIG-008', 'GR1C' UNION ALL
Select 'ARC-NONGIG-008', 'GR2' UNION ALL
Select 'ARC-NONGIG-008', 'GR4' UNION ALL
Select 'C25000001', 'GR1A' UNION ALL
Select 'C25000001', 'GR1B' UNION ALL
Select 'C25000001', 'GR1C' UNION ALL
Select 'C25000001', 'GR2' UNION ALL
Select 'C25000001', 'GR4' UNION ALL
Select 'C25000002', 'GR1A' UNION ALL
Select 'C25000002', 'GR1B' UNION ALL
Select 'C25000002', 'GR1C' UNION ALL
Select 'C25000002', 'GR2' UNION ALL
Select 'C25000002', 'GR4' UNION ALL
Select 'C25000003', 'GR1A' UNION ALL
Select 'C25000003', 'GR1B' UNION ALL
Select 'C25000003', 'GR1C' UNION ALL
Select 'C25000003', 'GR2' UNION ALL
Select 'C25000003', 'GR4' UNION ALL
Select 'C27000001', 'GR1A' UNION ALL
Select 'C27000001', 'GR1B' UNION ALL
Select 'C27000001', 'GR1C' UNION ALL
Select 'C27000001', 'GR2' UNION ALL
Select 'C27000001', 'GR4' UNION ALL
Select 'C27000002', 'GR1A' UNION ALL
Select 'C27000002', 'GR1B' UNION ALL
Select 'C27000002', 'GR1C' UNION ALL
Select 'C27000002', 'GR2' UNION ALL
Select 'C27000002', 'GR4' UNION ALL
Select 'C27000003', 'GR1A' UNION ALL
Select 'C27000003', 'GR1B' UNION ALL
Select 'C27000003', 'GR1C' UNION ALL
Select 'C27000003', 'GR2' UNION ALL
Select 'C27000003', 'GR4' UNION ALL
Select 'C27000004', 'GR1A' UNION ALL
Select 'C27000004', 'GR1B' UNION ALL
Select 'C27000004', 'GR1C' UNION ALL
Select 'C27000004', 'GR2' UNION ALL
Select 'C27000004', 'GR4' UNION ALL
Select 'C27000005', 'GR1A' UNION ALL
Select 'C27000005', 'GR1B' UNION ALL
Select 'C27000005', 'GR1C' UNION ALL
Select 'C27000005', 'GR2' UNION ALL
Select 'C27000005', 'GR4' UNION ALL
Select 'C27000006', 'GR1A' UNION ALL
Select 'C27000006', 'GR1B' UNION ALL
Select 'C27000006', 'GR1C' UNION ALL
Select 'C27000006', 'GR2' UNION ALL
Select 'C27000006', 'GR4' UNION ALL
Select 'C27000007', 'GR1A' UNION ALL
Select 'C27000007', 'GR1B' UNION ALL
Select 'C27000007', 'GR1C' UNION ALL
Select 'C27000007', 'GR2' UNION ALL
Select 'C27000007', 'GR4' UNION ALL
Select 'C27000009', 'GR1A' UNION ALL
Select 'C27000009', 'GR1B' UNION ALL
Select 'C27000009', 'GR1C' UNION ALL
Select 'C27000009', 'GR2' UNION ALL
Select 'C27000009', 'GR4' UNION ALL
Select 'C27000010', 'GR1A' UNION ALL
Select 'C27000010', 'GR1B' UNION ALL
Select 'C27000010', 'GR1C' UNION ALL
Select 'C27000010', 'GR2' UNION ALL
Select 'C27000010', 'GR4' UNION ALL
Select 'C27000011', 'GR1A' UNION ALL
Select 'C27000011', 'GR1B' UNION ALL
Select 'C27000011', 'GR1C' UNION ALL
Select 'C27000011', 'GR2' UNION ALL
Select 'C27000011', 'GR4' UNION ALL
Select 'C27000012', 'GR1A' UNION ALL
Select 'C27000012', 'GR1B' UNION ALL
Select 'C27000012', 'GR1C' UNION ALL
Select 'C27000012', 'GR2' UNION ALL
Select 'C27000012', 'GR4' UNION ALL
Select 'C5000003', 'GR1A' UNION ALL
Select 'C5000003', 'GR1B' UNION ALL
Select 'C5000003', 'GR1C' UNION ALL
Select 'C5000003', 'GR2' UNION ALL
Select 'C5000003', 'GR4'

Declare @Id int
Declare @gid int
Declare @cid int
Declare @GroupName as Nvarchar(255)
Declare @CreditID int
Declare @CustomerId as Nvarchar(255)
set @Id = 1
set @gid = 1
set @cid = 1

While(@Id <= (Select Max(id) From @Customer))
begin
	Select @CustomerId = CustomerId, @GroupName = GroupName From @Customer Where Id = @Id
	
			SET @cid = 1

			while(@cid <= (select max(id) from @CreditTerm))
			begin
				Select @CreditID = CreditID From @CreditTerm Where Id =  @cid
				Exec sp_SaveCustomerCreditLimit @CustomerId, @GroupName, @CreditID, -1, 1									
				set @cid = @cid + 1
			end

	set @Id = @id + 1
end

delete From @Customer
delete from @CreditTerm
GO

Update C SET C.CreditLimit = Case WHEN ISNULL(C.CreditLimit, 0) < 0 THEN 0 ELSE ISNULL(C.CreditLimit, 0)  END
FROM Customer C WITH (NOLOCK)
GO