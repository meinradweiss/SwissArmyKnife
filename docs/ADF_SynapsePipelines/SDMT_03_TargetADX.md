# ADF Synspase Pipeline ADX




## Sample Pipeline, copy data from relatinal DB (SQL Server) to ADX database

### Pipeline overview

![Overview Picture](images/GetSlicedDataToADXOverview.png "Get Sliced Data To ADX Pipeline Overview")


### Pipeline If Condition, True activity

Drop existing extent.

</br>

![Overview Picture](images/GetSlicedDataToADXDropExistingExtentGeneral.png "Drop existing extent [General]")

</br>

![Overview Picture](images/GetSlicedDataToADXDropExistingExtentConnection.png "Drop existing extent [Command]")

</br>

![Overview Picture](images/GetSlicedDataToADXDropExistingExtentCommand.png "Drop existing extent [Command]")


|Porperty | Dynamic Content |
|---|---|
| Command | @activity('SetSlicedImportObjectStart').output.firstRow.ADX_DropExtentCommand |

