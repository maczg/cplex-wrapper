from fastapi import APIRouter

import xlwings as xw

router = APIRouter()

@router.get("/health")
async def health_check():
    return {"status": "ok"}

@router.post("/optimize")
async def optimize():
    import pandas as pd
    import subprocess

    ws = xw.Book("VNFNEW2_1.xlsm").sheets['Foglio1']
    # Z26:AD26 is the range of the decision variables for the active drones
    # eg. [0,1,0,1,1] means that drones 2 and 4,5 are active
    v1 = ws.range("Z26:AD26").value

    # Esegui il comando CPLEX (assicurati che cplex sia installato e configurato)
    result = subprocess.run(
        ["cplex", "-c", "read model.lp", "optimize", "display solution variables"],
        capture_output=True, text=True
    )

    return {
        "message": "Ottimizzazione completata",
        "output": result.stdout
    }