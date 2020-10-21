########################################################################
#																		
#	Script Title: Check-MCInventory											
#	Author: Brennan Custard												
#	Date: 10/21/2020														
#	Description: This script accepts a MicroCenter product URL and 
#	returns the inStock status			 		
#	DISCLAIMER: I AM NOT AFFILIATED WITH MicroCenter IN ANY WAY
#																		
########################################################################
#
#	Assumptions
#	Your product URI will be formatted similarly to the example below
#	https://www.microcenter.com/product/608318/amd-ryzen-7-3700x-matisse-36ghz-8-core-am4-boxed-processor-with-wraith-prism-cooler
#	Your mileage may vary based on the selected store/future site updates/etc...
#	If you do not specify repeatCount, you only want to check once
#	If you do not specify repeatInterval, the default wait is 30 seconds in between checks
#
#


param ($productUri, $repeatCount=1, $repeatInterval=30, [switch]$pushEnabled)
$counter = 1

cls

write-output "


   ________  _______ _   ______________   _____ __________  ________  ___________
  / ____/ / / / ___// | / / ____/_  __/  / ___// ____/ __ \/  _/ __ \/_  __/ ___/
 / /   / / / /\__ \/  |/ / __/   / /     \__ \/ /   / /_/ // // /_/ / / /  \__ \ 
/ /___/ /_/ /___/ / /|  / /___  / /     ___/ / /___/ _, _// // ____/ / /  ___/ / 
\____/\____//____/_/ |_/_____/ /_/     /____/\____/_/ |_/___/_/     /_/  /____/  
                                                                                 "

#Function to invoke the HTTP GET and determine if the item is in stock
function getMcHtml
	{
		$date = Get-Date
		#Get the HTML content of the provided product page
		$request = Invoke-WebRequest -URI $productUri
		#Get the title out of the ParsedHtml data
		$title = $request.ParsedHtml.title
		#Chop the HTML content into lines
		$request = $request.toString() -split "[`r`n]"
		#Find the inStock line
		$request = $request | Select-String "'inStock'"
		
		write-output "***********************************************"
		Write-Output $title
		
		#If the item is NOT currently in stock
		IF ($request -like "*False*")
			{
				write-output "Item is not in stock at $date..."
				#write-output "Test result is $request"
				$inStock = $false
			}
		
		#If the item IS currently in stock
		IF ($request -like "*True*")
			{
				write-output "Item is in stock as of $date!!!"
				#Beep the user's console
				[console]::beep(1000,1500)
				[console]::beep(1000,1500)
				[console]::beep(1000,1500)
				#write-output "Test result is $request"
				$inStock = $true
				IF ($pushEnabled -eq $true)
					{
						$pushMessage = "The itme you are monitoring at MicroCenter is now in stock. " + $title
						Send-PushoverMessage -title "Item In Stock" -message "$pushMessage" -sound "siren" -user "u1u24KYp2tAbk33xxQQ4S78rndVGi6" -token "an43nea6wojncnod7f32unz4ees66n"
					}
				pause
				Remove-Variable title -Force
				Remove-Variable request -Force
				exit
			}
		#Return the stock status for future use
		return $inStock
	}

#This loop runs while the counter is less than repeatCount
DO
	{
		#If we haven't run yet, don't bother sleeping
		IF ($counter -ne 1)
			{
				#Write-Output "Last stock status was $inStock..."
				Write-Output "Sleeping $repeatInterval seconds..."
				write-output "***********************************************"
				write-output "`n"
				write-output "`n"
				#Sleep in between each HTTP GET request
				Start-Sleep -seconds $repeatInterval
			}
		
		#Call the main function
		getMcHtml($productUri)
		
		#Increment the counter so we honor repeatCount
		$counter = $counter + 1
		
	
	} WHILE ($counter -le $repeatCount)