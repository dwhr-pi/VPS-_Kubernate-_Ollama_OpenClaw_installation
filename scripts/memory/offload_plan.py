"""Offline weight-budget arithmetic, NOT a hardware probe or a runtime guarantee."""
import argparse
import json
import math


def estimate(parameters_b, bits, ram_gib, vram_gib, ram_reserve=8, vram_reserve=2,
             overhead_percent=15, mode="split"):
    values = (parameters_b, bits, ram_gib, vram_gib, ram_reserve, vram_reserve, overhead_percent)
    if not all(math.isfinite(x) for x in values):
        raise ValueError("Nur endliche Zahlen erlaubt.")
    if parameters_b <= 0 or not 0 < bits <= 32 or min(values[2:]) < 0:
        raise ValueError("Parameter/Bits positiv, Speicher/Reserven nicht negativ angeben.")
    if mode not in ("split", "unified"):
        raise ValueError("Modus split oder unified waehlen.")
    if (ram_reserve > ram_gib or (mode == "split" and vram_gib > 0 and vram_reserve > vram_gib)
            or (mode == "unified" and max(ram_reserve, vram_reserve) > ram_gib)):
        raise ValueError("Reserve uebersteigt das angegebene Budget.")
    raw = parameters_b * 1e9 * bits / 8 / 1024**3
    weights = raw * (1 + overhead_percent / 100)
    if not math.isfinite(weights):
        raise ValueError("Eingaben zu gross fuer eine sinnvolle Schaetzung.")
    cpu_budget = ram_gib - ram_reserve
    gpu_budget = max(0, vram_gib - vram_reserve)
    if mode == "unified":
        budget = ram_gib - max(ram_reserve, vram_reserve)
        outcome = "weights_may_fit_shared_pool" if weights <= budget else "weights_exceed_budget"
    else:
        budget = cpu_budget + gpu_budget
        outcome = ("weights_may_fit_gpu" if weights <= gpu_budget else
                   "offload_may_be_possible" if weights <= budget else "weights_exceed_budget")
    if not math.isfinite(budget):
        raise ValueError("Speicherbudget zu gross.")
    return {"mode": mode, "raw_weights_gib": round(raw, 2),
            "weights_with_assumed_overhead_gib": round(weights, 2),
            "weight_budget_gib": round(budget, 2), "assessment": outcome,
            "runtime_guaranteed": False,
            "warnings": ["KV-Cache, Aktivierungen, Ladepeaks, Duplikate und Backendgrenzen separat pruefen.",
                         "Reserven sind Nutzereingaben; RAM/VRAM/Speicherplatz wurden nicht gemessen.",
                         "Unified-Modus zaehlt den RAM-Pool nur einmal; kein VRAM-Speed durch Offload."]}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--parameters-b", type=float, required=True)
    parser.add_argument("--bits", type=float, default=4)
    parser.add_argument("--ram-gib", type=float, required=True)
    parser.add_argument("--vram-gib", type=float, default=0)
    parser.add_argument("--ram-reserve", type=float, default=8)
    parser.add_argument("--vram-reserve", type=float, default=2)
    parser.add_argument("--overhead-percent", type=float, default=15)
    parser.add_argument("--mode", choices=("split", "unified"), default="split")
    opts = parser.parse_args(argv)
    try:
        print(json.dumps(estimate(**vars(opts)), indent=2, ensure_ascii=True))
    except ValueError as exc:
        parser.error(str(exc))


if __name__ == "__main__":
    main()
