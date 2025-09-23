
NBA Athletic Score Project Ismail Ismail
# 🏀 Do High-End Athletic Traits Translate into NBA Career Success?

## 🔍 Abstract  
This project investigates whether elite athletic traits measured at the NBA Draft Combine translate into longer, more successful NBA careers. Using Kaggle’s NBA dataset ([source](https://www.kaggle.com/datasets/wyattowalsh/basketball/data)), I cleaned and merged player combine results, draft history, and career stats into a single database.  

I created an **athletic score** by standardizing six key traits (height, wingspan ratio, vertical leap, bench press, agility time, sprint time). Career length (in years) was used as the main success metric.  

**Finding:** While athleticism provides obvious advantages, the data suggests **high-end athletic traits alone are not a reliable predictor of career longevity** in the NBA.  

---

## 🏀 Introduction  
- **Why it matters**: Scouts and front offices often overvalue athleticism in the draft. Players like **Jonathan Kuminga, Thon Maker, and Josh Jackson** highlight this dilemma — elite athletes who struggled to establish long careers.  
- **Research Question**:  
  > Do players with above-average athletic traits (measured at the Combine) have longer NBA careers compared to less athletic peers?  

---

## 📂 Data & Cleaning  
- Source: Kaggle NBA Dataset ([link](https://www.kaggle.com/datasets/wyattowalsh/basketball/data))  
- Steps Taken:  
  - Merged combine stats, draft info, and career data.  
  - Standardized height, wingspan, agility, sprint, etc.  
  - Created derived metrics (career length, wingspan ratio).  
  - Built SQL **views** to clean and restructure data.  

Example SQL Snippet:  
```sql
CREATE VIEW player_full_career AS
SELECT
    player_combine_draft.player_id,
    player_combine_draft.display_first_last,
    player_combine_draft.position,
    player_combine_draft.height_in,
    player_combine_draft.wingspan,
    player_combine_draft.vertical_leap,
    player_combine_draft.bench_reps,
    player_combine_draft.agility_time,
    player_combine_draft.sprint_time,
    player_combine_draft.draft_season,
    player_combine_draft.draft_round,
    player_combine_draft.overall_pick,
    player_combine_draft.drafted_team,
    common_player_info.from_year,
    common_player_info.to_year,
    (common_player_info.to_year - common_player_info.from_year + 1) AS career_length_years
FROM player_combine_draft
LEFT JOIN common_player_info
    ON player_combine_draft.player_id = common_player_info.person_id;
```
---

## 📈 Visuals (Tableau)  

1. **Scatter Plot: Athletic Score vs Career Length**  
   - Shows almost flat trendline → very weak relationship.  
   - ![Scatter Plot](ScatterPlot.png)  

2. **Bar Chart: Average Athletic Score & Career Length by Position**  
   - Top panel: Average athletic score for each position.  
   - Bottom panel: Average career length (years) for each position.  
   - Takeaway: Some positions (like PF-SF) appear to have both higher athletic scores and longer careers, but overall the relationship is inconsistent.    
   - ![Bar Chart](BarChart.png)  

---

## 📊 Results  

- **Scatter plot trendline** between athletic score and career length was nearly flat (R² ≈ close to 0).  
- **Draft round** showed stronger predictive power for career length than athletic traits.  
- **Position analysis** (Guards, Wings, Bigs) showed only slight differences — not driven by athletic score.  
- **Outliers** like Thon Maker and Josh Jackson highlight the issue: great athletes who didn’t last long in the league.  

---

## 💬 Discussion  

The data suggests that **high-end athletic traits alone are not reliable predictors of NBA career longevity**. While athleticism clearly provides an advantage in getting drafted, other factors seem to matter more for sustaining a career:  

- **Injuries**: Especially for players who rely heavily on athleticism, injuries can shorten careers quickly.  
- **Role fit**: Even highly athletic players can fail if their skillset doesn’t match team needs or if their position becomes less valued.  
- **Skill development**: Players who don’t expand their game beyond raw athleticism often see their careers cut short.  

📌 **Takeaway:** Teams should be cautious about overvaluing combine numbers without considering role adaptability, basketball IQ, and injury risk.  

---

## 🔮 Future Work

This analysis only measured **career length in years** as a proxy for success. Future extensions could:  
- Include **career quality** (All-Star appearances, advanced stats like WS/48 or BPM).  
- Control for **injury history** and role changes.  
- Compare across **eras** (e.g., 2000s vs modern pace-and-space NBA).  

---
