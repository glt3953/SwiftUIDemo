import CoreData

// CoreData持久化控制器
struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // 创建数据模型
        let model = NSManagedObjectModel()
        
        // 创建Item实体描述
        let itemEntity = NSEntityDescription()
        itemEntity.name = "Item"
        itemEntity.managedObjectClassName = "Item"
        
        // 添加timestamp属性
        let timestampAttribute = NSAttributeDescription()
        timestampAttribute.name = "timestamp"
        timestampAttribute.attributeType = .dateAttributeType
        timestampAttribute.isOptional = false
        
        // 设置实体的属性
        itemEntity.properties = [timestampAttribute]
        
        // 将实体添加到模型
        model.entities = [itemEntity]
        
        container = NSPersistentContainer(name: "SwiftUIDemo", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("无法加载CoreData存储: \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
} 