import Foundation

extension Credential {
    var isManuallyUpdatable: Bool {
           switch kind {
           case .mobileBankID:
               switch status {
               case .authenticating:
                   return true
               case .temporaryError:
                   return true
               case .created:
                   return true
               case .updated:
                   let now = Date()
                   if let date = statusUpdated, let threeMinutesAgo = Calendar.current.date(byAdding: .minute, value: -3, to: now) {
                       return date < threeMinutesAgo
                   } else {
                       return false
                   }
               default:
                   return false
               }
           case .password:
               switch status {
               case .sessionExpired:
                   return true
               default:
                   let now = Date()
                   if let date = sessionExpiryDate, let oneWeekBeforeSessionExpires = Calendar.current.date(byAdding: .day, value: -7, to: date) {
                       return now > oneWeekBeforeSessionExpires
                   } else {
                       return false
                   }
               }
           case .thirdPartyAuthentication:
               switch status {
               case .authenticationError:
                   return true
               case .sessionExpired:
                   return true
               default:
                   let now = Date()
                   if let date = sessionExpiryDate, let oneWeekBeforeSessionExpires = Calendar.current.date(byAdding: .day, value: -7, to: date) {
                       return now > oneWeekBeforeSessionExpires
                   } else {
                       return false
                   }
               }
           default:
               return false
           }
       }
}
