

import PlaygroundSupport


enum Position: String {
    case CEO
    case ProductManager
    case Developer
}

protocol Person {
    var name: String { get }
    var position: Position { get }
}

class Company {
    
    var ceo: Ceo?
    
    init() {
        print("\(Company.self) init")
        ceo = Ceo(name: "Thomas", company: self)
        ceo?.productManager?.printDevelopers()
        ceo?.productManager?.printCompany()
    }
    
    deinit {
        print("\(Company.self) deinit")
    }
}


class Ceo: Person {

    var name: String
    
    var position: Position = .CEO
    
    weak var company: Company?
    
    var productManager: ProductManager?
    
    init(name: String, company: Company?) {
        print("\(Ceo.self) \(name) init")
        self.name = name
        self.company = company
        productManager = ProductManager(name: "Natali", ceo: self, company: company)
    }
    
    deinit {
        print("\(Ceo.self) \(name) deinit")
    }
    
    let printProductManager = { (productManager: ProductManager?) -> Void in
        guard let manager = productManager else { return }
        print("Product manager - \(manager)")
    }
    
    let printWorkers = { (productManager: ProductManager?) -> Void in
        productManager?.printDevelopers()
    }
    
    let request: (String, Person) -> Void = { text, person -> Void in
        print("Question from \(person.position) \(person.name) - \(text)")
    }
}

class ProductManager: Person {
    
    var name: String
    
    var position: Position = .ProductManager
    
    weak var ceo: Ceo?
    weak var company: Company?
    
    var developers: [Developer?] = []
    
    init(name: String, ceo: Ceo?, company: Company?) {
        print("\(ProductManager.self) \(name) init")
        self.name = name
        self.ceo = ceo
        self.company = company
        developers.append(Developer(name: "Slave 1", productManager: self))
        developers.append(Developer(name: "Slave 2", productManager: self))
        startCommunicationBetweenDevelopers()
    }
    
    deinit {
        print("\(ProductManager.self) \(name) deinit")
    }
    
    func startCommunicationBetweenDevelopers() {
        
        for developer in developers {
            developer?.communication()
        }
    }
    
    func printDevelopers() {
        
        guard developers.isEmpty == false else { return }
        
        print("Developers list:")
        
        for dev in developers {
            
            guard let developer = dev else { return }
            print("\(developer.position) - \(developer.name)")
        }
    }
    
    func printCompany() {
        
        guard company != nil else { return }
        
        print("Company is printing:")
        
        if let ceo = ceo {
            print("\(ceo.position) - \(ceo.name)")
        }
        
        print("\(self.position) - \(self.name)")
        
        printDevelopers()
    }
    
    func requestToProductManager(question text: String, from person: Person) {
        print("Question from \(person.position) \(person.name) - \(text)")
    }
    
    func requestToCeo(question text: String, from person: Person) {
        ceo?.request(text, person)
    }
    
    func requestToDeveloper(question text: String, from person: Person, to name: String) {
        developers.filter { $0?.name == name }.map{ $0?.request(question: text, from: person) }
    }
}

class Developer: Person {
    
    var name: String
    
    var position: Position = .Developer
    
    weak var productManager: ProductManager?
    
    init(name: String, productManager: ProductManager) {
        print("\(Developer.self) \(name) init")
        self.name = name
        self.productManager = productManager
    }
    
    deinit {
        print("\(Developer.self) \(name) deinit")
    }
    
    func communication() {
        productManager?.requestToProductManager(question: "Продукт-менеджер, дай ТЗ", from: self)
        productManager?.requestToProductManager(question: "Продукт-менеджер, дай мне новую задачу", from: self)
        productManager?.ceo?.request("CEO, я хочу зарплату больше", self)
        productManager?.requestToDeveloper(question: "Ты говнокодер", from: self, to: name == "Slave 1" ? "Slave 2" : "Slave 1")
        productManager?.requestToDeveloper(question: "Я отправил тебе pull-request", from: self, to: name == "Slave 1" ? "Slave 2" : "Slave 1")
    }
    
    func request(question text: String, from person: Person) {
        print("Question from \(person.position) \(person.name) - \(text) to \(name)")
    }
}

var company: Company? = Company()
company = nil
