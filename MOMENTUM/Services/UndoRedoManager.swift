import Foundation

final class UndoRedoManager<T: Hashable> {
    private var undoStack: [T] = []
    private var redoStack: [T] = []
    private let limit: Int

    init(limit: Int = 30) {
        self.limit = limit
    }

    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }

    func push(_ state: T) {
        undoStack.append(state)
        if undoStack.count > limit {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }

    func undo(current: T) -> T? {
        guard let previous = undoStack.popLast() else { return nil }
        redoStack.append(current)
        return previous
    }

    func redo(current: T) -> T? {
        guard let next = redoStack.popLast() else { return nil }
        undoStack.append(current)
        return next
    }

    func reset() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
}
