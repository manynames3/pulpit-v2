import json
from pathlib import Path


GOLDEN_PATH = Path(__file__).resolve().parents[1] / "eval" / "retrieval-golden.json"


def load_golden_queries() -> list[dict]:
    with GOLDEN_PATH.open(encoding="utf-8") as handle:
        payload = json.load(handle)
    assert isinstance(payload, list)
    return payload


def test_retrieval_golden_contract_has_required_cases() -> None:
    samples = load_golden_queries()
    categories = {sample["category"] for sample in samples}

    assert "korean-natural-language-query" in categories
    assert "english-to-korean-concept-query" in categories
    assert "english-to-korean-topic-query" in categories
    assert "korean-morphology-case" in categories
    assert "source-snippet-source-card-expectation" in categories


def test_retrieval_golden_contract_shape() -> None:
    for sample in load_golden_queries():
        assert sample["id"]
        assert sample["question"]
        assert sample["category"]
        assert sample["subqueries"]
        assert sample["expected_terms"]
        assert sample.get("requires_source_snippets") is True

        assert all(isinstance(value, str) and value for value in sample["subqueries"])
        assert all(isinstance(value, str) and value for value in sample["expected_terms"])


def test_source_card_case_is_explicit() -> None:
    source_card_cases = [
        sample
        for sample in load_golden_queries()
        if sample.get("requires_source_cards") is True
    ]

    assert source_card_cases
    assert any(sample["id"] == "en-death-source-card" for sample in source_card_cases)
