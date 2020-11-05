##############################################################################
# Clear & Remove OneView Alerts  
#
# Script to Clear & Remove OneView Alerts via Menu selections
#
#  Note:  This is a non-cmdlet script, uses native "Invoke-RestMethod" commands
#  
# VERSION 4.10, 4.20, 5.00, 5.20, and 5.30, 5.40 
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

$version = "20201021"

write-host " "
write-host " "



# Force TLS1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Block of code for PowerShell certificate messages...
if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type)
{
$certCallback = @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;
    public class ServerCertificateValidationCallback
    {
        public static void Ignore()
        {
            if(ServicePointManager.ServerCertificateValidationCallback ==null)
            {
                ServicePointManager.ServerCertificateValidationCallback += 
                    delegate
                    (
                        Object obj, 
                        X509Certificate certificate, 
                        X509Chain chain, 
                        SslPolicyErrors errors
                    )
                    {
                        return true;
                    };
            }
        }
    }
"@
    Add-Type $certCallback
}
[ServerCertificateValidationCallback]::Ignore() 

$Appliance = Read-Host 'ApplianceName or IP'
if ( $creds ) {
    write-host "OneView Appliance login creds are in cache, re-use them?   (must answer: 'No' to re-enter, default = yes) "
    $choice = Read-Host " Re-use cached creds? "
    if ( $choice -like "n" -or $choice -like "no" -or $choice -like "No" ) { 
        $global:creds = @{}
    }
}
if ( -not $creds.domain ) {
    $global:creds = @{}
    $domain = Read-Host "Enter 'domain' or 'local' for user Login?"
    $creds.add('domain', $domain)
}
if ( -not $creds.user ) {
    $username = Read-Host "Enter Username?"
    $creds.add('user', $username)
}
if ( -not $creds.pass ) {
    $securedpassword = Read-Host "Enter Password for user `"${username}`" " -AsSecureString
    $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securedpassword)
    $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    $creds.add('pass', $password)
}


######################################################
# Now connect to the OneView appliance
######################################################

# header needs to be a object
$myheader = @{"Content-Type"="application/json"
                "x-api-version"=2} 

# body needs to be a text - JSON
if ( $creds.domain -eq 'local' ) {
    $mybodyjson = "{  `"userName`": `"$($creds.user)`", `"password`": `"$($creds.pass)`"  }"
} else {
    $mybodyjson = "{  `"userName`": `"$($creds.user)`", `"password`": `"$($creds.pass)`", `"authLoginDomain`": `"$($creds.domain)`"  }"
}


     write-host -foreground Cyan "`nConnecting to the OneView Appliance... $Appliance as $($creds.user) "


   
    Try
        { 

        $mysession = Invoke-RestMethod -Uri "https://$Appliance/rest/login-sessions" -Method Post -Headers $myheader -body $mybodyjson 

        }
    Catch
        {

       write-host "`n`n ERROR - unable to connect to the OneView Appliance! `n`n"    
       Write-Error -Message "Please check the OneView access and login credentials" -ErrorAction Stop 
        
        }

    # Session needs to be PS Object
    $session_info = @{"Auth"="$($mysession.SessionID)"
                        "Content-Type"="application/json"
                        "x-api-version"=2}

   #  write-host = $mysession.SessionID


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

        
        "A1" {        
        
        $fout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=severity EQ 'Critical'" -Method Get -Headers $session_info 
        
          write-host `n ""
          write-host  "Alert Count: " $fout.count  
          write-host `n ""
          
          If ($fout.count -gt 25) {
        
        write-host `n"Displaying only the First 5 and Last 5 Alerts"

        $fout.members | select-object -first 5 -last 5 Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host
              
        }

        Else
        
        {
        
        $fout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host
         
         }
        }
               
        
        
        "A2" {
        
        
        $eout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Active'" -Method Get -Headers $session_info
        
          write-host `n ""
          write-host  "Alert Count: " $eout.count
          write-host `n ""  
                
         If ($eout.count -gt 25) {
              
             write-host `n"Displaying only the First 5 and Last 5 Alerts" 
                
             $eout.members | select-object -first 5 -last 5 select-object @{N="State"; E={$_.alertState}}, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, Severity, Description | ft | Out-Host 

                }
                
                Else   
        
           {
             $eout.members | select-object @{N="State"; E={$_.alertState}}, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, Severity, Description | ft | Out-Host 
         
         }
        }
          
       
       
        "A3" {
        
              $str = Read-Host 'Start Date (yyyy-mo-dy)'
              $stra = ($str + "T23:59:59.000Z") 
                       
              $end = Read-Host 'End Date (yyyy-mo-dy)'
              $enda = ($end + "T00:00:00.000Z")
                      
           
          $gout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=created gt $enda&filter=created le $stra"  -Method Get -Headers $session_info
           
          write-host `n ""
          write-host  "Alert Count: " $gout.count
          write-host `n ""  
                   

        If ($gout.count -gt 25) {
         
          
          write-host `n"Displaying only the First 5 and Last 5 Alerts"
          
          
          $gout.members | select-object -first 5 -last 5 Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host
           
           }
           
           Else 

          {

          $gout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host

          }
         }
        

        
        "A4" {   $Encl = Read-Host 'Enclosure Name'
                 $mybay = ', bay '
                 $Bay = Read-Host 'Server Bay#'
                 $YN = Read-Host "Active Alerts Only? (yes)" 
                 $myserver = ($Encl + $mybay + $Bay)
               
                 write-host $myserver

               
                 $hout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=resourceName EQ '$myserver'" -Method Get -Headers $session_info
               
                         
               If ($YN -eq 'yes') {
                    
                   $hsout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Active'&filter=resourceName EQ '$myserver'" -Method Get -Headers $session_info
                   
                   write-host `n ""
                   write-host  "Active Alert Count: " $hsout.count  
                   write-host  "Alert Total: " $hout.total
                   write-host `n ""
                   
                   
                   $hsout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
                      
                      }                 
                           
               Else
            
                   {
                   

                   write-host `n ""
                   write-host  "Alert Count: " $hout.count  
                                   
                                      
                   $hout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host
                               
               }               
              }
          
            
        "A5"  {  
        
                 $Encl = Read-Host 'Enclosure Name'
                 $mybay = ', interconnect '
                 $Inter = Read-Host 'Interconnect Bay#'
                 $myinterconnect = ($Encl + $mybay + $Inter)
                 $YN = Read-Host "Active Alerts Only? (yes)"

                 write-host $myinterconnect 

                 $iout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=resourceName EQ '$myinterconnect'" -Method Get -Headers $session_info
              
          
            If ($YN -eq 'yes') {
            
          
            $isout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Active'&filter=resourceName EQ '$myinterconnect'" -Method Get -Headers $session_info
            
            write-host `n ""
            write-host  "Active Alert Count: " $isout.count  
            write-host  "Alert Total: " $iout.total
            write-host `n ""
            
            
            $isout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
       
            
            }  

                       
            Else

               {
       
            write-host `n ""
            write-host  "Alert Count: " $iout.count  
                      
            $iout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 

             }
            } 

        
        
        "A6" {    
        
                  $Profile = Read-Host 'Profile Name'
                  $YN = Read-Host "Active Alerts Only? (yes)"

            $pout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=resourceName EQ '$Profile'" -Method Get -Headers $session_info
            
            
            If ($YN -eq 'yes') {
            
            $psout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Active'&filter=resourceName EQ '$Profile'" -Method Get -Headers $session_info
            
            write-host `n ""
            write-host  "Active Alert Count: " $psout.count  
            write-host  "Alert Total: " $pout.total
            write-host `n ""
            
            $psout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
            
                      
            }  

                       
            Else

               {
               
                          
            write-host `n ""
            write-host  "Alert Count: " $pout.count  
          
            
            $pout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 

                     
             }
            }
                 
         
           
        "B1"  {
        
              write-host `n ""               
              $str = Read-Host 'Start Date (yyyy-mo-dy)'
              $stra = ($str + "T23:59:59.000Z") 
                       
              $end = Read-Host 'End Date (yyyy-mo-dy)'
              $enda = ($end + "T00:00:00.000Z")
                      
           
          $adout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Active'&filter=created gt $enda&filter=created le $stra"  -Method Get -Headers $session_info
           
          write-host `n ""
          write-host  `n"Alert Count: " $adout.count
          write-host `n ""  
                
              
          If ($adout.count -gt 25) { 

              write-host `n"Displaying only the First 5 and Last 5 Alerts"
                 
              $adout.members | select-object -first 5 -last 5 Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host
           
            }
            
             Else 

             {
             
              $adout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host
 
                 } 
         
         $YN = Read-Host `n"Do you want to mark Active Alerts as Cleared? (yes)"
         
          write-host `n ""

         $counter = 0
         $count = 0 
              
          
            If ($YN -eq 'yes') {

            
            # Loop through Alerts to Change Status to Cleared                       
                 
                  $adout.members.uri | ForEach-Object {

                         
                 $adcout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Put -Headers $session_info -body "{ `"alertState`": `"Cleared`" }" 
              
                             
                 Write-host "." -NoNewline
                 
                 $count = $count + 1


                        If ($count -eq 50) {

                        Write-host "."`r
                        $count = 0

                        } 
                 
                 $counter = $counter + 1 
                 
                }
               } 

                write-host `n ""
                write-host `n $counter " Active Alerts have been Cleared"`n 
                 
          } 

              

        "B2" {
        

              $acout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Active'" -Method Get -Headers $session_info
        
          write-host `n ""
          write-host  "Alert Count: " $acout.count  
          write-host `n ""
        
            
         
         If ($acout.count -gt 25) {
        
           write-host `n"Displaying only the First 5 and Last 5 Alerts"
        
           $acout.members | select-object -first 5 -last 5 @{N="State"; E={$_.alertState}}, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, Severity, Description | ft | Out-Host 
         
         }

         Else


          {


           $acout.members | select-object @{N="State"; E={$_.alertState}}, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, Severity, Description | ft | Out-Host 

         
           }
 
         $YN = Read-Host "Do you want to mark Active Alerts as Cleared? (yes)"
              
          
            write-host `n ""
            $counter = 0
            $count = 0
            
            If ($YN -eq 'yes') {
         
         
         
          # Loop through Alerts to Change Status to Cleared                       
                        
                          
                           
                        $acout.members.uri | ForEach-Object {

                        $accout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Put -Headers $session_info -body "{ `"alertState`": `"Cleared`" }"
                    
                                                              
                        Write-host "." -NoNewline

                        $count = $count + 1


                        If ($count -eq 50) {

                        Write-host "."`r
                        $count = 0

                        }
                         
                        $counter = $counter + 1 
                       
                       }
                      }

                       write-host `n ""      
                       write-host $counter " Active Alerts have been Cleared"`n    
                  
                 }
               
     
       
        "B3" {   
        
        
                 $Encl = Read-Host 'Enclosure Name'
                 $mybay = ', bay '
                 $Bay = Read-Host 'Server Bay#'
                 $myserver = ($Encl + $mybay + $Bay)
               
               
                  write-host $myserver

        
               $asout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Active'&filter=resourceName EQ '$myserver'" -Method Get -Headers $session_info
                   
                   write-host `n ""
                   write-host  "Alert Count: " $asout.count  
                   write-host `n ""
                   
               
                If ($asout.count -gt 25) {
                
                 write-host `n"Displaying only the First 5 and Last 5 Alerts"

                 $asout.members | select-object -first 5 -last 5 Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host  

                
                }
                
                Else   
               
                {

                 $asout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
               
                   }          
         
               $YN = Read-Host "Do you want to mark Active Alerts as Cleared? (yes)"

               write-host `n ""
               $counter = 0
               $count = 0
          
            If ($YN -eq 'yes') {

            
            # Loop through Alerts to Change Status to Cleared                       
                
                           
                $asout.members.uri | ForEach-Object {

                #  Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Put -Headers $session_info -body "{ `"alertState`": `"Cleared`" }"  
              
                   $ascout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Put -Headers $session_info -body "{ `"alertState`": `"Cleared`" }" 

                                          
                 Write-host "." -NoNewline

                 $count = $count + 1


                        If ($count -eq 50) {

                        Write-host "."`r
                        $count = 0

                        }

                 $counter = $counter + 1
                 
               }  
             }   
                write-host `n ""
                write-host $counter " Active Alerts for Server $myserver have been Cleared"`n    

            }   
               
          

                       
        "B4" {   
        
        
                 $Encl = Read-Host 'Enclosure Name'
                 $mybay = ', interconnect '
                 $Inter = Read-Host 'Interconnect Bay#'
                 $myinterconnect = ($Encl + $mybay + $Inter)
                  

                 write-host $myinterconnect   
        
           
               $iout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Active'&filter=resourceName EQ '$myinterconnect'" -Method Get -Headers $session_info
            
                   write-host `n ""
                   write-host  "Active Alert Count: " $iout.count
                   write-host `n ""  

                      If ($iout.count -gt 25) {

                       write-host `n"Displaying only the First 5 and Last 5 Alerts"

                       $iout.members | select-object -first 5 -last 5 Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
   
                       }

                       Else

                       {

                       $iout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
          
                       }
              
              
              $YN = "no"
              
              
               If ($iout.count -eq 0) {

               write-host "NO Active Alerts found for $myinterconnect"

              }
               
               Else

               {
               
               $YN = Read-Host "Do you want to mark Active Alerts as Cleared? (yes)"

               }

               write-host `n ""
               $counter = 0
               $count = 0
          
            If ($YN -eq 'yes') {


             # Loop through Alerts to Change Status to Cleared

              
                $iout.members.uri | ForEach-Object {

                          
                $iscout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Put -Headers $session_info -body "{ `"alertState`": `"Cleared`" }" 

                                          
                 Write-host "." -NoNewline

                 $count = $count + 1


                        If ($count -eq 50) {

                        Write-host "."`r
                        $count = 0

                        }

                 $counter = $counter + 1
                 
               }  
             }   
                
                
                write-host `n ""
                write-host $counter " Active Alerts for $myinterconnect have been Cleared"`n    

            }   
             
   
            

        "B5" { 
        
        
           $Profile = Read-Host 'Profile Name'
                  

            write-host $Profile  
            
            
              
               $paout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Active'&filter=resourceName EQ '$Profile'" -Method Get -Headers $session_info
            
                   write-host `n ""
                   write-host  "Active Alert Count: " $paout.count
                   write-host `n ""  

                      If ($paout.count -gt 25) {

                       write-host `n"Displaying only the First 5 and Last 5 Alerts"

                       $paout.members | select-object -first 5 -last 5 Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
   
                       }

                       Else

                       {

                       $paout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
          
                       }


              $YN = "no"


              If ($paout.count -eq 0) {

               write-host "NO Active Alerts found for $Profile"

              }
               
               Else

               {
               
               $YN = Read-Host "Do you want to mark Active Alerts as Cleared? (yes)"

               }

               write-host `n ""
               $counter = 0
               $count = 0
          
            If ($YN -eq 'yes') {


             # Loop through Alerts to Change Status to Cleared
                     
                           
                $paout.members.uri | ForEach-Object {

                #  Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Put -Headers $session_info -body "{ `"alertState`": `"Cleared`" }"  
              
                $pascout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Put -Headers $session_info -body "{ `"alertState`": `"Cleared`" }" 

                                          
                 Write-host "." -NoNewline

                 $count = $count + 1


                        If ($count -eq 50) {

                        Write-host "."`r
                        $count = 0

                        }

                 $counter = $counter + 1
                 
               }  
             }   
                write-host `n ""
                write-host $counter " Active Alerts for Server Profile $Profile have been Cleared"`n    

            }   
       
      
       
       
        "C1" {
        
              $dout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Cleared'" -Method Get -Headers $session_info
        
          write-host `n ""
          write-host  "Alert Count: " $dout.count  
          write-host `n ""
        
            
         
         If ($dout.count -gt 25) {
        
           write-host `n"Displaying only the First 5 and Last 5 Alerts"
        
           $dout.members | select-object -first 5 -last 5 @{N="State"; E={$_.alertState}}, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, Severity, Description | ft | Out-Host 
        
        }

         Else


          {


           $dout.members | select-object @{N="State"; E={$_.alertState}}, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, Severity, Description | ft | Out-Host 

         
           }
 
         $YN = Read-Host "Do you want to Remove Cleared Alerts? (yes)"
              
          
            write-host `n ""
            $counter = 0
            $count = 0
            
            If ($YN -eq 'yes') {
         
         
         
          # Loop through Alerts to Remove Cleared Alerts                      
                        
                          
                           
                        $dout.members.uri | ForEach-Object {


                      $dcout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Delete -Headers $session_info 
                        
                        
                   # $dcout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Put -Headers $session_info -body "{ `"alertState`": `"Cleared`" }" 
                    
                                                              
                        Write-host "." -NoNewline
                        $count = $count + 1


                        If ($count -eq 50) {

                        Write-host "."`r
                        $count = 0

                        }
                         
                        $counter = $counter + 1 
                       
                       }
                      }

                       write-host `n ""      
                       write-host $counter " Cleared Alerts have been Removed"`n    
                  
                 }
              
       
        
        "C2" { 


              $str = Read-Host 'Start Date (yyyy-mo-dy)'
              $stra = ($str + "T23:59:59.000Z") 
                       
              $end = Read-Host 'End Date (yyyy-mo-dy)'
              $enda = ($end + "T00:00:00.000Z")
                      
           
          $ddout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=created gt $enda&filter=created le $stra&filter=alertState EQ 'Cleared'"  -Method Get -Headers $session_info
           
          write-host `n ""
          write-host  "Alert Count: " $ddout.count
          write-host `n ""  
                   

        If ($ddout.count -gt 25) {
         
          
          write-host `n"Displaying only the First 5 and Last 5 Alerts"
          
          
          $ddout.members | select-object -first 5 -last 5 Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host
           
           }
           
           Else 

          {

          $ddout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host

          }
        
        
            $YN = Read-Host "Do you want to Remove Cleared Alerts? (yes)"
              
          
            write-host `n ""
            $counter = 0
            $count = 0
            
            If ($YN -eq 'yes') {
         
         
         
          # Loop through Alerts to Remove Cleared Alerts                      
                        
                          
                           
                        $ddout.members.uri | ForEach-Object {


                           $ddcout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Delete -Headers $session_info  
                    
                                                              
                        Write-host "." -NoNewline

                        $count = $count + 1


                        If ($count -eq 50) {

                        Write-host "."`r
                        $count = 0

                        }
                         
                        $counter = $counter + 1 
                       
                       }
                      }

                       write-host `n ""      
                       write-host $counter " Cleared Alerts have been Removed"`n    
                  
                 }

                                    

       
               
         
        "C3" {   
        
        
                 $Encl = Read-Host 'Enclosure Name'
                 $mybay = ', bay '
                 $Bay = Read-Host 'Server Bay#'
                 $myserver = ($Encl + $mybay + $Bay)
               
               
                  write-host $myserver

        
               $dsout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Cleared'&filter=resourceName EQ '$myserver'" -Method Get -Headers $session_info
                   
                   write-host `n ""
                   write-host  "Cleared Alert Count: " $dsout.count  
                   write-host `n ""
                   
               
                If ($dsout.count -gt 25) {
                
                 write-host `n"Displaying only the First 5 and Last 5 Alerts"

                 $dsout.members | select-object -first 5 -last 5 Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host  

                
                }
                
                Else   
               
                {

                 $dsout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
               
                   }          
         
               $YN = Read-Host "Do you want to Remove Cleared Alerts? (yes)"

               write-host `n ""
               $counter = 0
               $count = 0
          
            If ($YN -eq 'yes') {

            
            # Loop through Alerts to Remove Cleared Alerts                       
                
                           
                $dsout.members.uri | ForEach-Object {

                             
                   $dscout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Delete -Headers $session_info

                                          
                 Write-host "." -NoNewline

                 $count = $count + 1


                        If ($count -eq 50) {

                        Write-host "."`r
                        $count = 0

                        }

                 $counter = $counter + 1
                 
               }  
             }   
                write-host `n ""
                write-host $counter " Cleared Alerts for Server $myserver have been Removed"`n    

            }   
               
          

                       
        "C4" {   
        
        
                 $Encl = Read-Host 'Enclosure Name'
                 $mybay = ', interconnect '
                 $Inter = Read-Host 'Interconnect Bay#'
                 $myinterconnect = ($Encl + $mybay + $Inter)
                  

                 write-host $myinterconnect   
        
           
               $diout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Cleared'&filter=resourceName EQ '$myinterconnect'" -Method Get -Headers $session_info
            
                   write-host `n ""
                   write-host  "Cleared Alert Count: " $diout.count
                   write-host `n ""  

                      If ($diout.count -gt 25) {

                       write-host `n"Displaying only the First 5 and Last 5 Alerts"

                       $diout.members | select-object -first 5 -last 5 Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
   
                       }

                       Else

                       {

                       $diout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
          
                       }
              
              
              $YN = "no"
              
              
               If ($diout.count -eq 0) {

               write-host "NO Cleared Alerts found for $myinterconnect"

              }
               
               Else

               {
               
               $YN = Read-Host "Do you want to Remove Cleared Alerts? (yes)"

               }

               write-host `n ""
               $counter = 0
               $count = 0
          
            If ($YN -eq 'yes') {


             # Loop through Alerts to Remove Cleared Alerts

              
                $diout.members.uri | ForEach-Object {

                          
                $dicout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Delete -Headers $session_info

                                          
                 Write-host "." -NoNewline

                 $count = $count + 1


                        If ($count -eq 50) {

                        Write-host "."`r
                        $count = 0

                        }

                 $counter = $counter + 1
                 
               }  
             }   
                write-host `n ""
                write-host $counter " Cleared Alerts for $myinterconnect have been Removed"`n    

            }   
             
   
            

        "C5" {
        
        
           $Profile = Read-Host 'Profile Name'
                  

            write-host $Profile  
            
            
              
               $dpout = Invoke-RestMethod -Uri "https://$Appliance/rest/alerts?start=0&count=75000&filter=alertState EQ 'Cleared'&filter=resourceName EQ '$Profile'" -Method Get -Headers $session_info
            
                   write-host `n ""
                   write-host  "Cleared Alert Count: " $dpout.count 
                   write-host `n ""  

                   

                      If ($dpout.count -gt 25) {

                       write-host `n"Displaying only the First 5 and Last 5 Alerts"

                       $dpout.members | select-object -first 5 -last 5 Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
   
                       }

                       Else

                       {

                       $dpout.members | select-object Severity, @{N="Resource"; E={$_.associatedResource.resourceName}}, Created, Modified, @{N="State"; E={$_.alertState}}, Description | ft | Out-Host 
          
                       }


              $YN = "no"


              If ($dpout.count -eq 0) {

               write-host "NO Cleared Alerts found for $Profile"

              }
               
               Else

               {
               
               $YN = Read-Host "Do you want to Remove Cleared Alerts? (yes)"

               }

               write-host `n ""
               $counter = 0
               $count = 0
          
            If ($YN -eq 'yes') {


             # Loop through Alerts to Remove Cleared Aterts
                     
                           
                $dpout.members.uri | ForEach-Object {

                             
                $dpcout = Invoke-RestMethod -Uri "https://$Appliance/$_" -Method Delete -Headers $session_info

                                          
                 Write-host "." -NoNewline

                 $count = $count + 1


                        If ($count -eq 50) {

                        Write-host "."`r
                        $count = 0

                        }

                 $counter = $counter + 1
                 
               }  
              }
                                          
                write-host `n ""
                write-host $counter " Cleared Alerts for Server Profile $Profile have been Removed"`n
                    
              }
            }
            
          
                        
            $_ =  Read-Host `n"Type M to load the menu again or Q / Enter to quit"  
                 
                
           
           
         }
          
          
           While (($_ -eq "M"))   


            
           
           
           Write-Host `n"Enter or 'Q' Pressed... dropping to shell" -foregroundcolor Green 
          
                   
           $yesno = Read-Host `n`n"Do you want to end session with the $Appliance (yes/no)"  
           
            If ($yesno -eq 'yes') { 
              
            Invoke-RestMethod  -Uri "https://$Appliance/rest/login-sessions" -Method Delete -Headers $session_info
            
             }
            
            
                
          
      
        

       