"""Offline retrieval evaluation of supplied rankings; never calls a model or database."""
import argparse
import json
import math
from pathlib import Path


def evaluate(dataset, predictions, k=3):
    if type(k) is not int or not 1 <= k <= 100:
        raise ValueError('k muss zwischen 1 und 100 liegen')
    queries = dataset['queries']
    if not queries or len({query['id'] for query in queries}) != len(queries):
        raise ValueError('Nichtleere, eindeutige Testfragen erforderlich')
    if not isinstance(predictions, dict) or set(predictions) != {query['id'] for query in queries}:
        raise ValueError('Genau eine Rangliste fuer jede Testfrage erforderlich')
    scores = []
    for query in queries:
        relevant = set(query['relevant'])
        forbidden = set(query.get('forbidden', []))
        ranked = predictions[query['id']]
        if (not relevant or not isinstance(ranked, list) or any(not isinstance(x, str) for x in ranked)
                or len(set(ranked)) != len(ranked) or relevant & forbidden):
            raise ValueError('Ungueltige Relevanz-/ACL-/Rankingdaten')
        top = ranked[:k]
        hits = sum(item in relevant for item in top)
        reciprocal = next((1 / (index + 1) for index, item in enumerate(top) if item in relevant), 0)
        scores.append({'id': query['id'], 'precision_at_k': hits / k,
                       'recall_at_k': hits / len(relevant), 'reciprocal_rank_at_k': reciprocal,
                       'forbidden_hits': sum(item in forbidden for item in top)})
    mean = lambda key: math.fsum(row[key] for row in scores) / len(scores)
    return {'scope': 'supplied-retrieval-rankings-only; not answer quality or datastore ACL enforcement',
            'k': k, 'queries': scores, 'precision_at_k': mean('precision_at_k'),
            'recall_at_k': mean('recall_at_k'), 'mrr_at_k': mean('reciprocal_rank_at_k'),
            'forbidden_hits': sum(row['forbidden_hits'] for row in scores)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--dataset', required=True, type=Path)
    parser.add_argument('--predictions', required=True, type=Path)
    parser.add_argument('--k', type=int, default=3)
    args = parser.parse_args()
    try:
        data = evaluate(json.loads(args.dataset.read_text()), json.loads(args.predictions.read_text()), args.k)
        print(json.dumps(data, indent=2))
    except (ValueError, KeyError, TypeError, OSError) as error:
        parser.error(str(error))
    return 1 if data['forbidden_hits'] else 0


if __name__ == '__main__':
    raise SystemExit(main())
