import CalculusQuery
import CalculusLowering
namespace CalculusQueryExportLink
theorem mark_body_identity : CalculusQuery.exportMarkBody = CalculusLowering.markBody := rfl
#print axioms mark_body_identity
end CalculusQueryExportLink
