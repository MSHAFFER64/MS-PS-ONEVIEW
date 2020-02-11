##########################################################################################################################################################################
#
# Datacenter creation script
#
# Purpose: to demonstrate creation of datacenters with racks, populating them based on servers already present in OneView and associating remote support info from csv file
#
# November 2019 keenan.sugg@hpe.com
#
# v0.2 - changed datacenter name to be company name instead of store number and minor tweaks. spreadsheet updated with new alternate e-mail
#
##########################################################################################################################################################################


# Preloads

  # Import-Module HPOneView.420

  # $OneView = "CO1-SY12KB17U30.alf1.global.tslabs.hpecorp.net"

  # $creds = Get-Credential 


# connect to OV instance

 # Connect-HPOVMgmt -Hostname $OneView -Credential $creds



# Grab the input file


   # $csv = Import-CSV "cvs file name"    

   
# Moved adding remote support contacts out of every-line loop as there are only two contacts covering all systems.

    $line = $csv | Select-Object -First 1
    

# Note - Get-HPOVRemoteSupportContact only accepts "name" as a selection criteria

    $rscontactname = $line.'Primary Contact First Name' + " " + $line.'Primary Contact Last Name'

    Write-Host Contact from input file $rscontactname

    $rscontactobject = Get-HPOVRemoteSupportContact -Name $rscontactname | select-object -First 1 -ErrorAction SilentlyContinue

    $rscontactpresent = $rscontactobject.firstName  + " " + $rscontactobject.lastName

    Write-Host Contact in system $rscontactpresent

    if ($rscontactname -eq $rscontactpresent) 

        {
    
            Write-Host Remote Support Contact Present

        }

        Else

        {

            $line1 = $csv | Select-Object -First 1
    
            New-HPOVRemoteSupportContact -Firstname $line1.'Primary Contact First Name' -Lastname $line1.'Primary Contact Last Name' -Email $line1.'Primary Contact Email' -PrimaryPhone $line1.'Primary Contact Primary Phone' -AlternatePhone $line1.'Primary Contact Alternate Phone' -Language en -Default

            New-HPOVRemoteSupportContact -Firstname $line1.'Secondary Contact First Name' -Lastname $line1.'Secondary Contact Last Name' -Email $line1.'Secondary Contact Email' -PrimaryPhone $line1.'Secondary Contact Primary Phone' -AlternatePhone $line1.'Secondary Contact Alternate Phone' -Language en -Default

        }
    

# loop through CSV

    foreach ($line in $csv) 

    {

        # check to see if server is on this instance

        $servershouldbe = $line.'Serial Number'

        Write-Host Server should be $servershouldbe

        $serverpresent = Get-HPOVServer | Where-Object {$_.serialNumber -eq $line.'Serial Number'} -ErrorAction SilentlyContinue

        Write-Host Server present $serverpresent.serialNumber
    
       if ($serverpresent.serialNumber -eq $line.'Serial Number') 
        # if ($serverpresent -eq $servershouldbe) 

            {

                # Grab the Server Object
    
                $mycurrentserver = Get-HPOVServer | Where-Object {$_.serialNumber -eq $line.'Serial Number'}  -ErrorAction SilentlyContinue

                # check for and create Data Center if needed - names must be unique

                $datacenternameshouldbe = $line.'Company Name'

                Write-Host Datacenter should be $datacenternameshouldbe

                $datacenterpresent = Get-HPOVDataCenter -Name $datacenternameshouldbe -ErrorAction SilentlyContinue
    
                Write-Host Datacenter found is $datacenterpresent.name
    
               if ($datacenterpresent.name -eq $datacenternameshouldbe)

                     {
        
                     Write-Host DataCenter $datacenterpresent.name already exists

                      }

                 Else

                      {
        
                       Write-Host DataCenter $datacenternameshouldbe being created
                
                      #Define the required values.  size, power and cooling can be anything but must be present

                      $DataCenter1Name = $line.'Company Name'
    
                      $DataCenter1Width = 10

                      $DataCenter1Depth = 10

                      $DataCenter1Address1  = $line.'Address'

                      $DataCenter1Address2  = ' ';
 
                      $DataCenter1City      = $line.'City'

                      $DataCenter1State     = $line.'State'

                      $DataCenter1Country   = 'US';

                      $DataCenter1PostCode  = $line.'Zip'

                      $DataCenter1PowerCosts       = 0.10;

                      $DataCenter1CoolingCapacity  = 350;

                      #NOTE this assumes there are only the same two contacts everywhere

                      $DataCenter1PrimaryContact = Get-HPOVRemoteSupportContact | Select-Object -First 1

                      $DataCenter1SecondaryContact = Get-HPOVRemoteSupportContact | Select-Object -Last 1

                      #actually create the datacenter

                      New-HPOVDataCenter -Name $DataCenter1Name -Width $DataCenter1Width -Depth $DataCenter1Depth -Address1  $DataCenter1Address1 -Address2 $DataCenter1Address2 -City $DataCenter1City -State $DataCenter1State -Country $DataCenter1Country -PostCode $DataCenter1PostCode -PrimaryContact $DataCenter1PrimaryContact -SecondaryContact $DataCenter1SecondaryContact -PowerCosts $DataCenter1PowerCosts -CoolingCapacity $DataCenter1CoolingCapacity

                      Get-HPOVDataCenter -Name $line.'Company Name'

                     }


               # check for and create rack if needed - names must be unique, prefix with datacenter number

               $racknameshouldbe = $line.'Data Center' + " " + $line.'Rack'
               $rackpresent = Get-HPOVRack -Name $racknameshouldbe  -ErrorAction SilentlyContinue
    
               if ($rackpresent.name -eq  $racknameshouldbe)

                   {

                   Write-Host Rack $rackpresent.name already exists

                   }

               Else

                   {

                   Write-Host Rack $racknameshouldbe being created
                
                   New-HPOVRack -name  $racknameshouldbe

                   }

              # Grab the rack object

              Write-Host $racknameshouldbe
            
              $mycurrentrack = Get-HPOVRack -Name $racknameshouldbe

              # Grab the DataCenter Object

             # $mydcname = $line.'Company Name'

            #  Write-Host $mydcname

              $mycurrentdatacenter = Get-HPOVDataCenter -Name $line.'Company Name'



              # Put Rack in Datacenter

              Add-HPOVRackToDataCenter -InputObject $mycurrentrack -DataCenter $mycurrentdatacenter -X 1 -Y 1

              # Put Server in Rack

              Add-HPOVResourceToRack -InputObject $mycurrentserver -Rack $mycurrentrack -ULocation $line.'U Location'

              }

    }