  

  

- AWS Budget Setup
    
    IAM users cannot access the billing details, Even if they have admin access.
    
    For that enable billing access to IAM users.
    
    Root Account ⇒ Billing and cost management ⇒ Billing and payments ⇒ [ Enable ] IAM user and role access to billing information.
    
    Now we set a Budget:
    
    Billing and Cost management ⇒ Budgets ⇒ Create Budget ⇒ 1. budget setup [ use a template ] 2. select template [ Zero spend budget ] 3. fill in details and create it.
    
    the budget is created. whenever you spend more than one cent it will notify you.