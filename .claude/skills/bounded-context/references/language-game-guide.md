# Language Game Concepts and Analysis Method Guide

## Wittgenstein's Language Games

### Core Concept

In his later work *Philosophical Investigations*, Ludwig Wittgenstein fundamentally shifted the view on the meaning of language.

**Early period (*Tractatus Logico-Philosophicus*):** Language "pictures" the world → words have fixed meanings
**Later period (*Philosophical Investigations*):** The meaning of a word is its **use** in the language (§43)

> "Die Bedeutung eines Wortes ist sein Gebrauch in der Sprache."
> (The meaning of a word is its use in the language.)

### What Are Language Games?

- The use of words is like a "game": there are participants, rules, and purposes
- The same word operates under different rules in different games (contexts)
- Game rules are not defined in advance but formed through practice
- "Family resemblance": there is no common essence to all games — only a network of similarities

### Key Implications

1. **Meaning is not in the dictionary:** Observe actual usage, not dictionary definitions
2. **Context determines meaning:** The same word has different meanings in different "games"
3. **Rules emerge from practice:** Bottom-up observation matters more than top-down definitions

---

## Application to Software Design

### Why Language Games Are Effective for DDD

DDD's core concept "Ubiquitous Language" requires consistent terminology within a context.
However, the criteria for **where to draw context boundaries** tend to be ambiguous.

Introducing the language game perspective:

- **Context boundary** = boundary where different language games are played
- **Ubiquitous language** = the rule system within a specific language game
- **Context discovery** = finding situations where "the same word is used in different games"

### MinoDriven Approach: Purpose-Driven Language Game Analysis

@MinoDriven (Daiya Seba) treats the actor's **purpose** as the context of the language game:

```text
Actor × Purpose → Language Game (Context) → Rule Set → Bounded Context
```

This clarifies "why draw the boundary there":
**Because different purposes cause different rules to apply to the same words.**

---

## Concrete Example: "商品" (Product) in an EC Site

### Game 1: Purchasing Game (購買ゲーム)

- **Participant:** 購入者 (Buyer)
- **Purpose:** Find and purchase desired products
- **Meaning of "商品":** Object of purchase
- **Related attributes:** 商品名、価格（税込表示価格）、レビュー評価、在庫有無、カテゴリ
- **Rules:**
  - 在庫がなければ購入できない
  - 価格は税込で表示する
  - レビューは購入者のみ投稿できる

### Game 2: Sales Management Game (販売管理ゲーム)

- **Participant:** 出品者/販売者 (Seller)
- **Purpose:** Sell products for profit
- **Meaning of "商品":** Asset that generates profit through sales
- **Related attributes:** 商品名、原価、販売価格、利益率、在庫数、仕入先
- **Rules:**
  - 利益率が閾値以下なら値上げを検討する
  - 在庫が閾値以下なら自動発注する
  - 販売実績に基づいて価格を調整する

### Game 3: Logistics Game (物流ゲーム)

- **Participant:** 物流担当/倉庫管理者 (Logistics/Warehouse manager)
- **Purpose:** Deliver products accurately and efficiently
- **Meaning of "商品":** Object of delivery and storage
- **Related attributes:** 重量、サイズ、配送区分、保管条件、SKU
- **Rules:**
  - 重量とサイズで配送料が決まる
  - 温度管理が必要な商品は専用ラインで配送
  - 同一倉庫の商品はまとめて配送可能

### Analysis Result

The same word "商品" is used in three different games. In each game:
- The required attributes differ
- The applicable rules differ
- The concerns differ

→ These are candidates for three different bounded contexts.

---

## How to Conduct Analysis

### Step 1: Collect Terms

- Gather major nouns and verbs from conversations with domain experts, existing documents, and code
- Pay special attention to terms "everyone assumes they know" (implicit polysemy lurks there)

### Step 2: Observe Usage

For each term:
- **Who** uses it (Actor)
- **For what purpose** (Purpose)
- **Under what rules**

Don't ask for dictionary definitions — ask about **actual usage scenarios**.

> Good question: 「『商品』という言葉を使うとき、どんな作業をしていますか？」
> Bad question: 「『商品』の定義は何ですか？」

### Step 3: Discover Semantic Divergence

When the same term is used by different actors/purposes:
- Do the attributes differ?
- Do the rules differ?
- Does the lifecycle differ?

If any answer is "yes," it's a candidate for a context boundary.

### Step 4: Validate Boundaries

For discovered boundary candidates:
- Does splitting at this boundary make terminology consistent within each context?
- Can inter-context interactions be clearly defined?
- Does it align with team structure (Conway's Law)?

---

## Relationship with Other Methods

### Event Storming

- Event Storming explores the domain starting from **events**
- Language game analysis starts from **how terms are used**
- Complementary: drill down into terms found in events discovered via Event Storming

### Domain Storytelling

- Domain Storytelling illustrates **the flow of actor actions**
- Language game analysis focuses on **changes in term meanings** within those flows
- Points where "the same noun refers to different things depending on context" are clues for context boundaries

### Context Mapping

- Context Mapping defines **relationships between contexts**
- Language game analysis supports **discovering contexts themselves**
- Use in sequence: Language game analysis → Context discovery → Context Mapping
