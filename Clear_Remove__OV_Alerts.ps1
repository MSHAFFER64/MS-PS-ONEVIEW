##############################################################################
# Clear & Remove OneView Alerts  
#
# Script to Clear & Remove OneView Alerts via Menu selections
#  
# VERSION 4.10, 4.20, 5.00, 5.20 
# 
#  Author: mark.shaffer@hpe.com 
#
# (C) Copyright 2013-2018 Hewlett Packard Enterprise Development LP 
##############################################################################
<#
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
#>
##############################################################################

Write-Host `n"Select PS CmdLet Module to Import HPOneView.410, HPOneView.420, HPOneView.500, or HPOneView.520"`n $ncVer -ForeGroundColor Cyan 
Write-Host -NoNewLine "<" -foregroundcolor Magenta
Write-Host -NoNewLine "Select PS Module"
Write-Host -NoNewLine ">"`n -foregroundcolor Magenta

Write-Host -NoNewLine `t`n"1 =" -foregroundcolor Green
Write-Host -NoNewLine " HPOneView.410"
Write-Host -NoNewLine `t`n"2 =" -foregroundcolor Yellow
Write-Host -NoNewLine " HPOneView.420"
Write-Host -NoNewLine `t`n"3 =" -foregroundcolor cyan
Write-Host -NoNewLine " HPOneView.500" 
Write-Host -NoNewLine `t`n"4 =" -foregroundcolor White
Write-Host -NoNewLine " HPOneView.520"`n`n  
 

$mod = Read-Host "Which Module to Load (1 or 2 or 3 or 4)?" 

    Switch ($mod) {
        "1" { 
        
           if (-not (get-module HPOneView.410)) 
        
              {Import-Module HPOneView.410}

             Else

           {Write-Host `n"PS CmdLet Module HPOneView.410 already loaded - skipping"`n $ncVer -ForeGroundColor White} 

             
           }

        "2" { 

           if (-not (get-module HPOneView.420)) 
        
              {Import-Module HPOneView.420}
             
             Else

           {Write-Host `n"PS CmdLet Module HPOneView.420 already loaded - skipping"`n $ncVer -ForeGroundColor White}
            
            
           }

        "3" { 

           if (-not (get-module HPOneView.500)) 
        
              {Import-Module HPOneView.500}
             
             Else

           {Write-Host `n"PS CmdLet Module HPOneView.500 already loaded - skipping"`n $ncVer -ForeGroundColor White}
            
            
          }

          "4" { 

           if (-not (get-module HPOneView.520)) 
        
              {Import-Module HPOneView.520}
             
             Else

           {Write-Host `n"PS CmdLet Module HPOneView.520 already loaded - skipping"`n $ncVer -ForeGroundColor White}
            
            
           }

         }       
# First connect to the HP OneView appliance if not already connected.
if (-not $ConnectedSessions)  
{
    Write-Host -NoNewLine `n`n"Connect to Appliance"`n`n 
	
    $Appliance = Read-Host 'ApplianceName or IP'
        $AUTHDomain = Read-Host 'Domain (Local or AD/LDAP)' 
	$Username  = Read-Host 'Username'
	$Password  = Read-Host 'Password' -AsSecureString

    $ApplianceConnection = Connect-HPOVMgmt -Hostname $Appliance -AuthLoginDomain $AUTHDomain -Username $Username -Password $Password
     
 }   
    Else
{

    Write-Host "Already Connected to $Appliance - skipping"
        
}

###########################################################################

do
{ 
# Load-Menu
 
#function Load-Menu {  
#[cmdletbinding()]
#param() }

# {
# $foregroundcolor = Green

 Remove-Variable -Name AllCluster -ErrorAction SilentlyContinue

Write-Host `n"List or Clear or Remove Alerts Menu"`n $ncVer -ForeGroundColor Green 
Write-Host -NoNewLine "<" -foregroundcolor Green
Write-Host -NoNewLine "List Alerts"
Write-Host -NoNewLine ">" -foregroundcolor Green
Write-Host -NoNewLine "["
Write-Host -NoNewLine "A" -foregroundcolor Green
Write-Host -NoNewLine "]"

Write-Host -NoNewLine `t`n "A1 - " -foregroundcolor Green
Write-host -NoNewLine "List All Critical Alerts"
Write-Host -NoNewLine `t`n "A2 - " -foregroundcolor Green
Write-host -NoNewLine "List All Active Alerts"
Write-Host -NoNewLine `t`n "A3 - " -foregroundcolor Green
Write-host -NoNewLine "List Alerts by Date Range"
Write-Host -NoNewLine `t`n "A4 - " -foregroundcolor Green
Write-host -NoNewLine "List Alerts by Server" 
Write-Host -NoNewLine `t`n "A5 - " -foregroundcolor Green
Write-host -NoNewLine "List Alerts by Interconnect" 
Write-Host -NoNewLine `t`n "A6 - " -foregroundcolor Green
Write-host -NoNewLine "List Alerts by Profile"`n`n

Write-Host -NoNewLine "<" -foregroundcolor Yellow
Write-Host -NoNewLine "Clear Active Alerts"
Write-Host -NoNewLine ">" -foregroundcolor Yellow
Write-Host -NoNewLine "["
Write-Host -NoNewLine "B" -foregroundcolor Yellow
Write-Host -NoNewLine "]"

Write-Host -NoNewLine `t`n "B1 - " -foregroundcolor Yellow
Write-host -NoNewLine "Clear Active Alerts by Date Range"
Write-Host -NoNewLine `t`n "B2 - " -foregroundcolor Yellow
Write-host -NoNewLine "Clear All Active Alerts"
Write-Host -NoNewLine `t`n "B3 - " -foregroundcolor Yellow
Write-host -NoNewLine "Clear Active Alerts by Server" 
Write-Host -NoNewLine `t`n "B4 - " -foregroundcolor Yellow
Write-host -NoNewLine "Clear Active Alerts by Interconnect" 
Write-Host -NoNewLine `t`n "B5 - " -foregroundcolor Yellow
Write-host -NoNewLine "Clear Active Alerts by Profile"`n`n


Write-Host -NoNewLine "<" -foregroundcolor Red
Write-Host -NoNewLine "Remove Cleared Alerts"
Write-Host -NoNewLine ">" -foregroundcolor Red
Write-Host -NoNewLine "["
Write-Host -NoNewLine "C" -foregroundcolor Red
Write-Host -NoNewLine "]"

Write-Host -NoNewLine `t`n "C1 - " -foregroundcolor Red
Write-host -NoNewLine "Remove All Alerts with Cleared Status"
Write-Host -NoNewLine `t`n "C2 - " -foregroundcolor Red
Write-host -NoNewLine "Remove All Cleared Alerts by Date Range"
Write-Host -NoNewLine `t`n "C3 - " -foregroundcolor Red
Write-host -NoNewLine "Remove All Cleared Alerts by Server" 
Write-Host -NoNewLine `t`n "C4 - " -foregroundcolor Red
Write-host -NoNewLine "Remove All Cleared Alerts by Interconnect" 
Write-Host -NoNewLine `t`n "C5 - " -foregroundcolor Red
Write-host -NoNewLine "Remove All cleared Alerts by Profile"`n`n

 $sel = Read-Host "Which option?"

    Switch ($sel) {
        "A1" {Get-HPOVAlert -severity Critical | Out-Host}
        "A2" {Get-HPOVAlert -AlertState Active | Out-Host}
          
        "A3" { $str = Read-Host 'Start Date (yyyy-mo-dy)'
               $end = Read-Host 'End Date (yyyy-mo-dy)'
                          
             Get-HPOVAlert -Start "$str" -End "$end" | Out-Host}



        "A4" {   $Encl = Read-Host 'Enclosure Name'
                 $Bay = Read-Host 'Server Bay#'
                 $YN = Read-Host "Active Alerts Only? (yes)" 
               #  $out = $null
               
               
               
               If ($YN -eq 'yes') {$out = Get-HPOVServer -Name "$Encl, Bay $Bay" | Get-HPOVAlert -AlertState 'Active' | Out-Host
               
                             
                Write-host -NoNewLine `n"If No Active Alerts Listed then No Active Alerts for Server Bay $Bay was found"`n -foregroundcolor cyan}   
             
             Else
            
                   {Get-HPOVServer -Name "$Encl, Bay $Bay" | Get-HPOVAlert | Out-Host}

               }               

          
            
        "A5"  {  $Encl = Read-Host 'Enclosure Name'
                 $Inter = Read-Host 'Interconnect Bay#'
                 $YN = Read-Host "Active Alerts Only? (yes)"
              #   $out = $null
          
            If ($YN -eq 'yes') {$out= Get-HPOVInterconnect -Name "$Encl, interconnect $Inter" | Get-HPOVAlert -AlertState 'Active'| Out-Host
            
            
            Write-host -NoNewLine `n"If No Active Alerts Listed then No Active Alerts for Interconnect Bay $Inter was found"`n -foregroundcolor cyan}  

                       
            Else

               {Get-HPOVInterconnect -Name "$Encl, interconnect $Inter" | Get-HPOVAlert | Out-Host}

               }


        "A6" {    $Profile = Read-Host 'Profile Name'
                  $YN = Read-Host "Active Alerts Only? (yes)"

            If ($YN -eq 'yes') {Get-HPOVServerProfile -Name "$Profile" | Get-HPOVAlert -AlertState 'Active' | Out-Host
                       
                        Write-host -NoNewLine `n"If No Active Alerts listed then No Active Alerts for Profile $Profile was found"`n -foregroundcolor cyan}
            
            Else

             {Get-HPOVServerProfile -Name "$Profile" | Get-HPOVAlert | Out-Host}

            }
                 
         
           
        "B1" { $str = Read-Host 'Start Date (yyyy-mo-dy)'
               $end = Read-Host 'End Date (yyyy-mo-dy)'
                          
             Get-HPOVAlert -Start "$str" -End "$end" -AlertState 'Active'| Set-HPOVAlert -Cleared | Out-Host

             }

        "B2" {Get-HPOVAlert -AlertState Active | Set-HPOVAlert -Cleared | Out-Host }

        "B3" {   $Encl = Read-Host 'Enclosure Name'
                 $Bay = Read-Host 'Server Bay#'
                                                
               Get-HPOVServer -Name "$Encl, Bay $Bay" | Get-HPOVAlert -AlertState 'Active' | Set-HPOVAlert -Cleared | Out-Host
                          
               }

                       
        "B4" {   $Encl = Read-Host 'Enclosure Name'
                 $Inter = Read-Host 'Interconnect Bay#'
               
              Get-HPOVInterconnect -Name "$Encl, interconnect $Inter" | Get-HPOVAlert -AlertState 'Active' | Set-HPOVAlert -Cleared | Out-Host   
              
               }


        "B5" { $Profile = Read-Host 'Profile Name'
                  

           Get-HPOVServerProfile -Name "$Profile" | Get-HPOVAlert -AlertState 'Active'| Set-HPOVAlert -Cleared | Out-Host

             }
                 
          
        "C1" {Get-HPOVAlert -AlertState 'Cleared' | Remove-HPOVAlert | Out-Host}
        "C2" { $str = Read-Host 'Start Date (yyyy-mo-dy)'
               $end = Read-Host 'End Date (yyyy-mo-dy)'
           
           Get-HPOVAlert -Start "$str" -End "$end" -AlertState 'Cleared' | Remove-HPOVAlert | Out-Host
        
           } 
           

        "C3" {   $Encl = Read-Host 'Enclosure Name'
                 $Bay = Read-Host 'Server Bay#'
                 
               
              Get-HPOVServer -Name "$Encl, Bay $Bay" | Get-HPOVAlert -AlertState 'Cleared' | Remove-HPOVAlert | Out-Host
              
              }

                        
        "C4" {   $Encl = Read-Host 'Enclosure Name'
                 $Inter = Read-Host 'Interconnect Bay#'
                

             Get-HPOVInterconnect -Name "$Encl, interconnect $Inter" | Get-HPOVAlert -AlertState 'Cleared' | Remove-HPOVAlert | Out-Host

             }

       
        "C5" {    $Profile = Read-Host 'Profile Name'
               

            Get-HPOVServerProfile -Name "$Profile" | Get-HPOVAlert -AlertState 'Cleared' | Remove-HPOVAlert | Out-Host
            
            }

          }
                                      
         $_ =  Read-Host `n"Type Load-Menu to load the menu again or q / Enter to quit"  
                 
                   
          }  

          
           While (($_ -eq "Load-Menu"))     
           
           
           Write-Host `n"No input or 'q' seen... dropping to shell" -foregroundcolor Green 
          
                    
           $yesno = Read-Host `n`n"Do you want to disconnect from $Appliance (yes/no)"  
           
            If ($yesno -eq 'yes') {Disconnect-HPOVMgmt}
               