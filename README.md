# Expected output

```
**Device tags**

Device         Tags
------         ----
device1        asia, east, global
device2        asia, east, global
device3        africa, east, global
device4        africa, east, global
device5        americas, west, global
device6        americas, west, global
device7        europe, west, global
device8        europe, west, global

**Deployments**

Hub     Deployment name     Priority    Target conditions
---     -----------------   --------    ------------------
east    global-base         1           east OR west
east    global-color        2           east OR west
west    global-base         1           east OR west
west    global-color        2           east OR west
```
