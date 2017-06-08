param(
  [string]$solution
)

$files =  Get-ChildItem *.sln,*.csproj,*.sqlproj,AssemblyInfo.cs -recurse;

Get-Content $solution |
  Select-String 'Project\(' |
    ForEach-Object {
      $projectParts = $_ -Split '[,=]' | ForEach-Object { $_.Trim('[ "{}]') };
	  $oldGuid = $projectParts[3];
	  $newGuid = [GUID]::NewGuid();
	  $files |
		Foreach-Object {
			$c = ($_ | Get-Content -encoding utf8) 
			$c = $c -replace $oldGuid, $newGuid
			$c = $c -replace $oldGuid.ToLower(), $newGuid
			[IO.File]::WriteAllText($_.FullName, ($c -join "`r`n"))
		}
	  
    
	 #New-Object PSObject -Property @{
       # Name = $projectParts[1];
        #File = $projectParts[2];
        #Guid = $projectParts[3]
     # }
    }