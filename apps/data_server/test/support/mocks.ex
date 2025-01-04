Mox.defmock(DataServer.MockStorage, for: DataServer.Behaviours.Storage)

Application.put_env(:data_server, :storage, DataServer.MockStorage)
