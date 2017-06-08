param(
  [string]$solution,
  [string]$oldNP,
  [string]$newNP
)

function RefreshGuids(){
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
}


function RefreshNamespaces(){
	Get-ChildItem *.sln,*.csproj,*.sqlproj,*.cs,*.cshtml -recurse |
		Foreach-Object {
			$c = ($_ | Get-Content -encoding utf8) 
			$c = $c -replace $oldNP, $newNP
			[IO.File]::WriteAllText($_.FullName, ($c -join "`r`n"))
		}
}

function RefreshProjectNames(){
		Get-ChildItem *.sln,*.csproj,*.sqlproj,*.config -Recurse | ForEach { 	
		if ($_.Name.IndexOf($oldNP) -ne -1) { 
			Try{
				Rename-Item -Path $_.FullName -NewName $_.Name.replace($oldNP, $newNP) 
			}
			Catch [system.exception]{
				'problem with $_.FullName' 
			}
		}
	} 

}

function RefreshDirectories(){
	Get-ChildItem -dir -Recurse | ForEach { 
	if ($_.Name.IndexOf($oldNP) -ne -1) { 
		Try{
			$newPath = $_.FullName.replace($oldNP, $newNP)
			
			If (Test-Path $newPath){
				Remove-Item $newPath -force -recurse
			}
			
			Rename-Item -Path $_.FullName -NewName $_.Name.replace($oldNP, $newNP) 
		}
		Catch [system.exception]{
			'problem with $_.FullName' 
		}
	}
} 
}

RefreshGuids 
RefreshNamespaces
RefreshProjectNames
RefreshDirectories