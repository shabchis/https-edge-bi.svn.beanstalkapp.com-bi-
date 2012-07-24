SELECT     CASE WHEN CHARINDEX('];', [UserName]) = 0 THEN [UserName] ELSE substring([UserName], 0, CHARINDEX('|', [UserName])) END AS UserName, 
                      CASE WHEN CHARINDEX('];', [UserName]) = 0 THEN NULL ELSE substring([UserName], CHARINDEX('.&[', [UserName]) + 3, CHARINDEX('];', [UserName], 
                      CHARINDEX('.&[', [UserName])) - (CHARINDEX('.&[', [UserName]) + 3)) END AS AccountID, Operation, Server, [Database], Cube, Path, CASE WHEN CHARINDEX('Books\', 
                      [Path]) != 0 THEN substring([Path], CHARINDEX('Books\', [Path]), CHARINDEX('\', [Path], CHARINDEX('Books\', [Path]) + 6) - CHARINDEX('Books\', [Path])) 
                      WHEN CHARINDEX('Users\EDGE\', [Path]) != 0 THEN substring([Path], CHARINDEX('Users\EDGE\', [Path]), CHARINDEX('\', [Path], CHARINDEX('Users\EDGE\', [Path]) 
                      + 11) - CHARINDEX('Users\EDGE\', [Path])) ELSE [Path] END AS BookName, CASE WHEN CHARINDEX('Books\', [Path]) 
                      != 0 THEN 'Public' WHEN CHARINDEX('Users\EDGE\', [Path]) != 0 THEN 'Private' ELSE 'No Book' END AS BookType, YEAR(EnterDate) AS EnterYear, 
                      MONTH(EnterDate) AS EnterMonth, DAY(EnterDate) AS EnterDay, DATEPART(HH, EnterDate) AS EnterHOUR, EnterDate
FROM         dbo.UserOper