import CalculusFragment
def main : IO Unit := do
  for line in CalculusFragment.fixtureJson do
    IO.println line
