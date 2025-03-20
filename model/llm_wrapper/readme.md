## Example usage functions 
``bash
pip3 install langchain-openai python-dotenv
```

Ensure ypui have a `.env` file with the following variables:

```
OPENAI_API_KEY=your_openai_api_key
``

# Usage examples
- Use the --message parameter to send a natural language query
# Calculate heat stress for crops
```python
python3 agent_caller.py --message "Calculate heat stress for corn with maximum temperature of 40°C"
```

# Calculate drought index
```python
python3 agent_caller.py --message "What's the drought index when precipitation is 30mm, evapotranspiration is 25mm, soil moisture is 15, and average temperature is 28°C?"
```

# Calculate yield risk
```python
python3 agent_caller.py --message "Calculate yield risk for cotton with GDD of 2300, precipitation of 950mm, pH of 6.0, and nitrogen content of 0.07 g/kg"
```