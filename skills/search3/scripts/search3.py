#!/usr/bin/env python3
import argparse, json, os, sys
from urllib.parse import urlencode

try:
    import requests
except ImportError:
    print("requests not installed. Install with: python3 -m pip install --user requests", file=sys.stderr)
    sys.exit(2)


def brave_hint(lang: str):
    # Built-in web_search tool handles Brave; this script doesn't call it.
    return {
        "note": "Brave search is available via OpenClaw web_search tool; this script handles Tavily/Firecrawl. Use web_search with search_lang/ui_lang set correctly.",
        "recommended": {
            "search_lang": lang or "zh-hans",
            "ui_lang": "zh-CN" if (lang or "zh-hans") == "zh-hans" else "zh-TW",
        },
    }


def tavily_search(query: str, max_results: int):
    key = os.environ.get("TAVILY_API_KEY")
    if not key:
        return None, "TAVILY_API_KEY missing"
    url = "https://api.tavily.com/search"
    payload = {
        "api_key": key,
        "query": query,
        "max_results": max_results,
        "include_answer": False,
        "include_images": False,
    }
    r = requests.post(url, json=payload, timeout=30)
    r.raise_for_status()
    data = r.json()
    out = []
    for item in data.get("results", [])[:max_results]:
        out.append({
            "title": item.get("title") or "",
            "url": item.get("url") or "",
            "snippet": (item.get("content") or "")[:400],
        })
    return out, None


def firecrawl_search(query: str, max_results: int):
    key = os.environ.get("FIRECRAWL_API_KEY")
    if not key:
        return None, "FIRECRAWL_API_KEY missing"

    # Firecrawl v1 search endpoint (hosted) is typically:
    # POST https://api.firecrawl.dev/v1/search
    url = "https://api.firecrawl.dev/v1/search"
    headers = {
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
    }
    payload = {
        "query": query,
        "limit": max_results,
    }
    r = requests.post(url, headers=headers, json=payload, timeout=45)
    r.raise_for_status()
    data = r.json()

    # Best-effort normalize. Different plans/versions may shape responses differently.
    results = data.get("data") or data.get("results") or []
    out = []
    for item in results[:max_results]:
        out.append({
            "title": item.get("title") or item.get("metadata", {}).get("title") or "",
            "url": item.get("url") or item.get("link") or "",
            "snippet": (item.get("snippet") or item.get("content") or item.get("markdown") or "")[:400],
        })
    return out, None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["all", "tavily", "firecrawl", "brave"], help="Provider or all (fallback)")
    ap.add_argument("--query", required=True)
    ap.add_argument("--max-results", type=int, default=8)
    ap.add_argument("--lang", default="zh-hans", help="Used only for Brave hint; Tavily/Firecrawl ignore")
    args = ap.parse_args()

    errors = []

    if args.mode == "brave":
        print(json.dumps({"providerUsed": "brave", "query": args.query, "results": [], "errors": [], "brave": brave_hint(args.lang)}, ensure_ascii=False, indent=2))
        return

    def ok(res):
        return isinstance(res, list) and any((r.get("url") or r.get("title")) for r in res)

    provider_used = None
    results = []

    if args.mode in ("tavily", "all"):
        try:
            res, err = tavily_search(args.query, args.max_results)
            if err:
                errors.append({"provider": "tavily", "error": err})
            elif ok(res):
                provider_used = "tavily"
                results = res
        except Exception as e:
            errors.append({"provider": "tavily", "error": str(e)})

    if provider_used is None and args.mode in ("firecrawl", "all"):
        try:
            res, err = firecrawl_search(args.query, args.max_results)
            if err:
                errors.append({"provider": "firecrawl", "error": err})
            elif ok(res):
                provider_used = "firecrawl"
                results = res
        except Exception as e:
            errors.append({"provider": "firecrawl", "error": str(e)})

    if args.mode != "all" and provider_used is None:
        # provider-only but failed
        provider_used = args.mode

    print(json.dumps({
        "providerUsed": provider_used or "none",
        "query": args.query,
        "results": results,
        "errors": errors,
        "brave": brave_hint(args.lang) if args.mode == "all" else None,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
