# Beispiel: OPC-UA Anlagenstatus

```env
OPCUA_ENDPOINT=opc.tcp://127.0.0.1:4840
OPCUA_NAMESPACE=2
OPCUA_NODE_STATUS=ns=2;s=Machine.Status
```

Standard: nur lesend. Schreibzugriffe nur mit Whitelist, Freigabe und Audit-Logging.
